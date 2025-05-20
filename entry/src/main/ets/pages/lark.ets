import { HashMap } from "@kit.ArkTS"
import mobShare from "@zztsdk/sharesdk"
import { HashonHelper } from "@zztsdk/zztcore"
import Utils from "../utils/Utils"
import { common } from "@kit.AbilityKit"

export const kRoute = "飞书"

@Entry({ routeName: kRoute })
@Component
struct Lark {
  scroller: Scroller = new Scroller()

  async aboutToAppear(): Promise<void> {
    await this.setLarkDevInfo()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Button("飞书是否安装")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Lark)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("飞书 Install:" + isInstall)
          })

        Button("飞书授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Lark)
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


        Button("飞书获取用户信息")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Lark)
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

        Button("飞书是否授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Lark)
            Utils.showMessage("飞书授权：" + await plat.isAuthValid())
          })

        Button("飞书取消授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Lark)
            plat.removeAccount()
          })
      }
    }
  }

  async setLarkDevInfo() {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的飞书APPKEY")
    map.set(mobShare.Platform_Info.APP_SECRET, "您的飞书APPSECRET")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.Lark, map)
  }
}