import { HashMap } from '@kit.ArkTS'
import mobShare from '@zztsdk/sharesdk'
import { HashonHelper } from '@zztsdk/zztcore'
import Utils from '../utils/Utils'
import { common } from '@kit.AbilityKit'

export const kRoute = "快手"

@Entry({ routeName: kRoute })
@Component
struct kuaiShou {
  scroller: Scroller = new Scroller()
  @State shareType: string = mobShare.ShareType.IMAGE
  @State butText: string = "分享图片"
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.IMAGE
  }

  async aboutToAppear(): Promise<void> {
    await this.setKSDevInfo()
  }

  setKSDevInfo() {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的快手APPKEY")
    map.set(mobShare.Platform_Info.APP_SECRET, "您的快手APPKEY")
    map.set(mobShare.Platform_Info.CALLBACK_ABILITY_NAME, "EntryAbility")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.KuaiShou, map)
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
                  Utils.showMessage("分享图片")
                  this.shareParam = {
                    utd: mobShare.ShareType.IMAGE
                  }
                  this.shareType = mobShare.ShareType.IMAGE
                  this.butText = "分享图片"
                }
              })
            Text('图片').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("50%")

          Row() {
            Radio({ value: mobShare.ShareType.VIDEO, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  Utils.showMessage("分享视频")
                  this.shareParam = {
                    utd: mobShare.ShareType.VIDEO
                  }
                  this.shareType = mobShare.ShareType.VIDEO
                  this.butText = "分享视频"
                }
              })
            Text('视频').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("50%")
        }.width("100%")

        Button(this.butText)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            this.shareParam.utd = this.shareType
            if (this.shareType == mobShare.ShareType.IMAGE) {
              this.shareParam.imageUri = (await Utils.selectMedia(getContext(this), "image"))[0]
            } else if (this.shareType == mobShare.ShareType.VIDEO) {
              this.shareParam.videoUri = (await Utils.selectMedia(getContext(this), "video"))[0]
            }
            if (!this.shareParam.videoUri && !this.shareParam.imageUri) {
              Utils.showMessage("请选择图片/视频")
              return
            }
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
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
          })


        Button("快手授权")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let message =
                  "auth onComplete:" + platform.getName() + ",action:" + action + ",map:" + HashonHelper.fromMap(res)
                Utils.showMessage(message)
              },
              onError: (platform: mobShare.IPlatform, action: number, error: Error) => {
                let message = "auth onError:" + platform.getName() + ",action:" + action + ",error:" + error.message
                Utils.showMessage(message)
              },
              onCancel: (platform: mobShare.IPlatform, action: number) => {
                let message = "auth onCancel:" + platform.getName() + ",action:" + action
                Utils.showMessage(message)
              }
            }
            let records: Array<mobShare.SharedParam> = new Array()
            records.push(this.shareParam)
            plat.setPlatformActionListener(receive)
            plat.authorize()
          })

        Button("快手获取用户信息")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                console.log("DB JSON:" + platform.getDb().exportData())
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

        Button("快手是否授权")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
            Utils.showMessage("快手授权：" + await plat.isAuthValid())
          })
        Button("快手取消授权")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
            plat.removeAccount()
          })

        Button("快手是否安装")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .margin(10)
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.KuaiShou)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("快手 Install:" + isInstall)
          })
      }
    }

  }

}