import { HashMap } from "@kit.ArkTS"
import mobShare from "@zztsdk/sharesdk"
import { HashonHelper } from "@zztsdk/zztcore"
import Utils from "../utils/Utils"
import { common } from "@kit.AbilityKit"
import ResourcesManager from "../utils/ResourcesManager"

export const kRoute = "钉钉"

@Entry({ routeName: kRoute })
@Component
struct dingding {
  scroller: Scroller = new Scroller()
  @State butText: string = "分享文字"
  @State shareText: string = ResourcesManager.text
  @State shareType: string = mobShare.ShareType.TEXT
  @State webUrl: string = ResourcesManager.webUrl
  @State webTitle: string = ResourcesManager.title
  @State imageUrl: string = ResourcesManager.imgUrl
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.TEXT
  }

  async aboutToAppear(): Promise<void> {
    await this.setDingdingDevInfo()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("分享内容类型")
          .fontSize(16)
          .margin(10)
        Row() {
          Row() {
            Radio({ value: mobShare.ShareType.IMAGE, group: 'ShareType' })
              .margin(10)
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  Utils.showMessage("分享文字")
                  this.shareParam = {
                    utd: mobShare.ShareType.TEXT
                  }
                  this.butText = "分享文字"
                  this.shareType = mobShare.ShareType.TEXT
                }
              })
            Text('文字').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")

          Row() {
            Radio({ value: mobShare.ShareType.VIDEO, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  Utils.showMessage("分享图片")
                  this.shareParam = {
                    utd: mobShare.ShareType.IMAGE
                  }
                  this.shareType = mobShare.ShareType.IMAGE
                  this.butText = "分享图片"
                }
              })
            Text('图片').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")


          Row() {
            Radio({ value: mobShare.ShareType.MIX_FILE, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  Utils.showMessage("分享链接")
                  this.shareParam = {
                    utd: mobShare.ShareType.WEBPAGE
                  }
                  this.shareType = mobShare.ShareType.WEBPAGE
                  this.butText = "分享链接"
                }
              })
            Text('链接').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")
        }.width("100%")

        TextArea({
          text: this.shareText,
          placeholder: '输入分享内容',
        }).onChange((value: string) => {
          this.shareText = value
        }).margin(10).visibility(this.shareType == mobShare.ShareType.TEXT ? Visibility.Visible : Visibility.None)

        TextArea({
          text: this.webUrl,
          placeholder: '输入分享链接url',
        }).onChange((value: string) => {
          this.webUrl = value
        }).margin(10).visibility(this.shareType == mobShare.ShareType.WEBPAGE ? Visibility.Visible : Visibility.None)

        TextArea({
          text: this.webTitle,
          placeholder: '输入分享链接标题',
        }).onChange((value: string) => {
          this.webTitle = value
        }).margin(10).visibility(this.shareType == mobShare.ShareType.WEBPAGE ? Visibility.Visible : Visibility.None)

        TextArea({
          text: this.imageUrl,
          placeholder: '输入图片链接',
        })
          .onChange((value: string) => {
            this.imageUrl = value
          })
          .margin(10)
          .visibility(this.shareType == mobShare.ShareType.WEBPAGE ? Visibility.Visible :
          Visibility.None)

        Button(this.butText)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            if (this.shareType == mobShare.ShareType.TEXT) {
              this.shareParam.content = this.shareText
            } else if (this.shareType == mobShare.ShareType.IMAGE) {
              let imageUris = await Utils.selectMedia(getContext(this), "image")
              this.shareParam.imageUri = imageUris[0]
            } else if (this.shareType == mobShare.ShareType.WEBPAGE) {
              this.shareParam.title = this.webTitle
              this.shareParam.url = this.webUrl
              this.shareParam.imageUrl = this.imageUrl
            }
            this.doShare()
          }).margin(10)

        Button("钉钉是否安装")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.DingDing)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("钉钉 Install:" + isInstall)
          })
      }
    }
  }

  async doShare() {
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.DingDing)
    let receive: mobShare.PlatformActionListener = {
      onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
        let message =
          "share onComplete:" + platform.getName() + ",action:" + action + ",map:" + HashonHelper.fromMap(res)
        Utils.showMessage(message)
      },
      onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
        let message = "share onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
        Utils.showMessage(message)
      },
      onCancel: (platform: mobShare.IPlatform, action: number) => {
        let message = "share onCancel:" + platform.getName() + ",action:" + action
        Utils.showMessage(message)
      }
    }
    let records: Array<mobShare.SharedParam> = new Array()
    records.push(this.shareParam)
    plat.setPlatformActionListener(receive)
    plat.share(records, getContext(this) as common.UIAbilityContext)
  }

  async setDingdingDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的钉钉APPKEY")
    map.set(mobShare.Platform_Info.CALLBACK_ABILITY_NAME, "EntryAbility")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.DingDing, map)
  }
}