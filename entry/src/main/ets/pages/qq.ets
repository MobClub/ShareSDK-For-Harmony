import mobShare from '@zztsdk/sharesdk'
import { HashMap } from '@kit.ArkTS'
import { HashonHelper } from '@zztsdk/zztcore'
import Utils from '../utils/Utils'
import { common } from '@kit.AbilityKit'
import ResourcesManager from '../utils/ResourcesManager'

export const kRoute = "QQ"

@Entry({ routeName: kRoute })
@Component
struct qq {
  scroller: Scroller = new Scroller()
  @State imageUrl: string = ResourcesManager.imgUrl
  @State webUrl: string = ResourcesManager.webUrl
  @State webTitle: string = ResourcesManager.title
  @State webDes: string = ResourcesManager.description
  @State butText: string = "分享链接"
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.WEBPAGE
  }

  async aboutToAppear(): Promise<void> {
    await this.setQQDevInfo()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("分享内容类型")
          .fontSize(16)
          .margin(10)

        TextArea({
          text: this.webUrl,
          placeholder: '输入分享链接url',
        }).onChange((value: string) => {
          this.webUrl = value
        }).margin(10)

        TextArea({
          text: this.webTitle,
          placeholder: '输入分享链接标题',
        }).onChange((value: string) => {
          this.webTitle = value
        }).margin(10)
        TextArea({
          text: this.webDes,
          placeholder: '输入分享链接描述',
        }).onChange((value: string) => {
          this.webDes = value
        }).margin(10)

        TextArea({
          text: this.imageUrl,
          placeholder: '输入图片链接',
        })
          .onChange((value: string) => {
            this.imageUrl = value
          })
          .margin(10)

        Button(this.butText)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            this.shareParam.title = this.webTitle
            this.shareParam.content = this.webDes
            this.shareParam.url = this.webUrl
            this.shareParam.imageUrl = this.imageUrl
            this.doShare()
          }).margin(10)

        Button("QQ是否安装")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("QQ Install:" + isInstall)
          })

        Button("QQ授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "authorize onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                Utils.showMessage(msg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "authorize onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                Utils.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "authorize onCancel:" + platform.getName() + ",action:" + action
                Utils.showMessage(msg)
              }
            }
            plat.setPlatformActionListener(receive)
            plat.authorize()
          })


        Button("QQ获取用户信息")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                Utils.showMessage(msg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "showUser onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                Utils.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "showUser onCancel:" + platform.getName() + ",action:" + action
                Utils.showMessage(msg)
              }
            }
            mobShare.ShareSDK.getInstance().setUIAbilityContext(getContext(this) as common.UIAbilityContext)
            plat.setPlatformActionListener(receive)
            plat.showUser()
          })

        Button("QQ是否授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
            Utils.showMessage("QQ授权：" + await plat.isAuthValid())
          })

        Button("QQ取消授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
            plat.removeAccount()
          })
      }
    }
  }

  async doShare() {
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.QQ)
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

  async setQQDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_ID, "您的QQ APPID")
    map.set(mobShare.Platform_Info.APP_KEY, "您的QQ APPKEY")
    map.set(mobShare.Platform_Info.REDIRECT_URL, "您的QQ回调URL")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.QQ, map)
  }
}