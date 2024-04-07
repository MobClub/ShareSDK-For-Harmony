import mobShare from '@mobsdk/sharesdk';
import { MobSDK } from '@mobsdk/mobcore'
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Scroll() {
      Column() {
        Text("ShareSDK DEMO")
          .width('100%')
          .margin(10)
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
        Button("初始化")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            MobSDK.init(getContext(this), "moba0b0c0d0", "5713f0d88511f9f4cf100cade0610a34")
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("同意隐私")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            MobSDK.submitPolicyGrantResult(true)
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("拒绝隐私")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            MobSDK.submitPolicyGrantResult(false)
          })
          .width('90%')
          .margin(10)
          .padding(15)
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
                let message = "share onComplete:" + platform.getName() + ",action:" + action
                this.showMessage(message)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let message = "share onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                this.showMessage(message)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let message = "share onCancel:" + platform.getName() + ",action:" + action
                this.showMessage(message)
              }
            }
            let plat = mobShare.ShareSDK.getInstance().getPlatform(mobShare.Platform.SYSTEM)
            plat.setPlatformActionListener(receive)
            plat.share(records, getContext(), {
              previewMode: mobShare.SharePreviewMode.DEFAULT,
              selectionMode: mobShare.SelectionMode.SINGLE
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
            let plat = mobShare.ShareSDK.getInstance().getPlatform(mobShare.Platform.HUAWEI)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "authorize onComplete:" + platform.getName() + ",action:" + action
                this.showMessage(msg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "authorize onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                this.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "authorize onCancel:" + platform.getName() + ",action:" + action
                this.showMessage(msg)
              }
            }
            plat.setPlatformActionListener(receive)
            plat.authorize(params)
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为获取用户信息")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            let plat = mobShare.ShareSDK.getInstance().getPlatform(mobShare.Platform.HUAWEI)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action
                let dbMsg = platform.getDb().exportData()
                this.showMessage(msg)
                this.showMessage("华为用户信息:" + dbMsg)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let msg = "showUser onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                this.showMessage(msg)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let msg = "showUser onCancel:" + platform.getName() + ",action:" + action
                this.showMessage(msg)
              }
            }
            plat.setPlatformActionListener(receive)
            plat.showUser()
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为是否授权")
          .onClick(() => {
            mobShare.ShareSDK.getInstance()
              .getPlatform(mobShare.Platform.HUAWEI)
              .isAuthValid()
              .then((isAuth) => {
                this.showMessage("HUAWEI isAuth:" + isAuth)
              })
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("华为取消授权")
          .onClick(() => {
            mobShare.ShareSDK.getInstance()
              .getPlatform(mobShare.Platform.HUAWEI)
              .removeAccount()
          })
          .width('90%')
          .margin(10)
          .padding(15)
      }
      .width('100%')
    }
    .height('100%')
    .align(Alignment.Top)
  }

  showMessage(message: string) {
    console.log(message)
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}