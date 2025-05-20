import mobShare from '@zztsdk/sharesdk'
import { HashonHelper } from '@zztsdk/zztcore'
import { promptAction } from '@kit.ArkUI'

export const kRoute = "Huawei"

@Entry({ routeName: kRoute })
@Component
struct huawei {
  scroller: Scroller = new Scroller()

  build() {
    Scroll(this.scroller) {
      Column() {
        Button("系统分享")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let records: Array<mobShare.SharedParam> = new Array()
            records.push({
              utd: mobShare.ShareType.TEXT,
              content: "测试分享文本",
            })
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let message =
                  "share onComplete:" + platform.getName() + ",action:" + action + ",map:" + HashonHelper.fromMap(res)
                console.log("share onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res))
                this.showMessage(message)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let message = "share onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                console.log(message)
                this.showMessage(message)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let message = "share onCancel:" + platform.getName() + ",action:" + action
                console.log(message)
                this.showMessage(message)
              }
            }
            mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SYSTEM).then((plat) => {
              plat.setPlatformActionListener(receive)
              plat.share(records, getContext(), {
                previewMode: mobShare.SharePreviewMode.DEFAULT,
                selectionMode: mobShare.SelectionMode.SINGLE
              })
            })
          })
          .width('90%')
          .margin(10)
          .padding(15)
        Button("华为授权")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let params = new Map<string, Object>()
            params.set("scopes", ['profile'])
            params.set("permissions", ['idtoken'])
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "authorize onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                console.log(msg)
                this.showMessage(msg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "authorize onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                console.log(msg)
                this.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "authorize onCancel:" + platform.getName() + ",action:" + action
                console.log(msg)
                this.showMessage(msg)
              }
            }
            mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.HUAWEI).then((plat) => {
              plat.setPlatformActionListener(receive)
              plat.authorize(params)
            })
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为获取用户信息")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                let dbMsg = platform.getDb().exportData()
                console.log(msg)
                console.log("dbMessage:" + dbMsg)
                this.showMessage(msg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "showUser onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                console.log(msg)
                this.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "showUser onCancel:" + platform.getName() + ",action:" + action
                console.log(msg)
                this.showMessage(msg)
              }
            }
            mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.HUAWEI).then((plat) => {
              plat.setPlatformActionListener(receive)
              plat.showUser()
            })
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为是否授权")
          .onClick(() => {
            mobShare.ShareSDK.getInstance()
              .getPlatformAsync(mobShare.Platform.HUAWEI).then((plat) => {
              plat.isAuthValid().then((isAuth) => {
                this.showMessage("HUAWEI isAuth:" + isAuth)
              })
            })
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为取消授权")
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.HUAWEI)
            plat.removeAccount()
          })
          .width('90%')
          .margin(10)
          .padding(15)
      }
    }
  }

  showMessage(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}

