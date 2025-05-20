import { HashMap } from "@kit.ArkTS"
import mobShare from "@zztsdk/sharesdk"
import { HashonHelper } from "@zztsdk/zztcore"
import Utils from "../utils/Utils"
import { common } from "@kit.AbilityKit"
import { CommonUtils } from "shareoutersdk"
import ResourcesManager from "../utils/ResourcesManager"

export const kRoute = "支付宝"

@Entry({ routeName: kRoute })
@Component
struct alipay {
  scroller: Scroller = new Scroller()
  @State butText: string = "分享文字"
  @State shareText: string = ResourcesManager.text
  @State shareType: string = mobShare.ShareType.TEXT
  @State imageType: string = "imageUrl"
  @State imageUrl: string = ResourcesManager.imgUrl
  @State webUrl: string = ResourcesManager.webUrl
  @State webTitle: string = ResourcesManager.title
  @State webDes: string = ResourcesManager.description
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.TEXT
  }

  async aboutToAppear(): Promise<void> {
    let sign = await CommonUtils.getSign()
    console.log("支付宝签名：" + sign)
    await this.setAlipayDevInfo()
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


        Row() {
          Row() {
            Radio({ value: "imageUrl", group: 'imageType' })
              .margin(10)
              .checked(true)
              .onChange((isChecked: boolean) => {
                this.imageType = "imageUrl"
                this.butText = "分享网络图片"
              })
            Text('网络图片').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")

          Row() {
            Radio({ value: "imagePath", group: 'imageType' })
              .margin(10)
              .checked(false)
              .onChange(async (isChecked: boolean) => {
                this.imageType = "imagePath"
                this.butText = "分享本地图片"
              })
            Text('本地图片').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")

          Row() {
            Radio({ value: "imageData", group: 'imageType' })
              .margin(10)
              .checked(false)
              .onChange(async (isChecked: boolean) => {
                this.imageType = "imageData"
                this.butText = "分享图片Data"
              })
            Text('图片(data)').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")
        }.visibility(this.shareType == mobShare.ShareType.IMAGE ? Visibility.Visible : Visibility.None)

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
          text: this.webDes,
          placeholder: '输入分享链接描述',
        }).onChange((value: string) => {
          this.webDes = value
        }).margin(10).visibility(this.shareType == mobShare.ShareType.WEBPAGE ? Visibility.Visible : Visibility.None)


        TextArea({
          text: this.imageUrl,
          placeholder: '输入图片链接',
        })
          .onChange((value: string) => {
            this.imageUrl = value
          })
          .margin(10)
          .visibility(this.canShowImageUrlTextArea() ? Visibility.Visible :
          Visibility.None)

        Button(this.butText)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            if (this.shareType == mobShare.ShareType.TEXT) {
              this.shareParam.content = this.shareText
            } else if (this.shareType == mobShare.ShareType.IMAGE) {
              if (this.imageType == "imageUrl") {
                this.shareParam.imageUrl = this.imageUrl
                this.shareParam.imageUri = undefined
                this.shareParam.imageData = undefined
              } else if (this.imageType == "imagePath") {
                let imageUris = await Utils.selectMedia(getContext(this), "image")
                this.shareParam.imageUri = imageUris[0]
                this.shareParam.imageUrl = undefined
                this.shareParam.imageData = undefined
              } else if (this.imageType == "imageData") {
                let resourceManager = getContext(this).resourceManager
                let imageArray = await resourceManager.getMediaContent($r("app.media.hhhh"));
                this.shareParam.imageData = imageArray;
                this.shareParam.imageUrl = undefined
                this.shareParam.imageUri = undefined
              }
            } else if (this.shareType == mobShare.ShareType.WEBPAGE) {
              this.shareParam.title = this.webTitle
              this.shareParam.description = this.webDes
              this.shareParam.url = this.webUrl
              this.shareParam.imageUrl = this.imageUrl
            }
            this.doShare()
          }).margin(10)

        Button("支付宝是否安装")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Alipay)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("支付宝 Install:" + isInstall)
          })
      }
    }
  }

  async doShare() {
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Alipay)
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

  async setAlipayDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_ID, "您的支付宝APPID")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.Alipay, map)
  }

  canShowImageUrlTextArea(): boolean {
    if (this.shareType == mobShare.ShareType.IMAGE) {
      return this.imageType == "imageUrl"
    } else {
      return this.shareType == mobShare.ShareType.WEBPAGE
    }
  }
}