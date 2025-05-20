import { HashMap } from '@kit.ArkTS'
import mobShare from '@zztsdk/sharesdk'
import Utils from '../utils/Utils'
import { common } from '@kit.AbilityKit'
import { HashonHelper } from '@zztsdk/zztcore'


export const kRoute = "抖音"

@Entry({ routeName: kRoute })
@Component
struct douyin {
  scroller: Scroller = new Scroller()
  shareTitle = ""
  shortTitle = ""
  tagOne: mobShare.hashTag = {}
  tagTwo: mobShare.hashTag = {}
  @State butText: string = "分享本地图片"
  @State shareType: string = mobShare.ShareType.IMAGE
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.IMAGE
  }

  async aboutToAppear(): Promise<void> {
    await this.setDouyinDevInfo()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("分享内容类型")
          .fontSize(16)
          .margin(10)

        Column() {
          TextArea({
            placeholder: '选填-输入标题',
          }).onChange((value: string) => {
            this.shareTitle = value
          }).margin(10)
          TextArea({
            placeholder: '选填-输入短标题',
          }).onChange((value: string) => {
            this.shortTitle = value
          }).margin(10)

          Text("选填-在短标题中插入话题,位置超过边界会插入在末尾")
            .margin(10)
          Row() {
            TextArea({
              placeholder: '输入话题1',
            }).onChange((value: string) => {
              this.tagOne.hashTag = value
            }).width("65%")
            TextInput({
              placeholder: '话题1位置',
            }).type(InputType.Number)
              .onChange((value: string) => {
                this.tagOne.start = Number(value)
              }).width("35%")
          }.width("100%")
          .margin(10)

          Row() {
            TextArea({
              placeholder: '输入话题2',
            }).onChange((value: string) => {
              this.tagTwo.hashTag = value
            }).width("65%")
            TextInput({
              placeholder: '话题2位置',
            }).type(InputType.Number)
              .onChange((value: string) => {
                this.tagTwo.start = Number(value)
              }).width("35%")
          }.width("100%")
          .margin(10)
        }

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
                  this.butText = "分享本地图片"
                  this.shareType = mobShare.ShareType.IMAGE
                }
              })
            Text('图片').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")

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
                  this.butText = "分享本地视频"
                }
              })
            Text('视频').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")


          Row() {
            Radio({ value: mobShare.ShareType.MIX_FILE, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  Utils.showMessage("分享图片视频混合")
                  this.shareParam = {
                    utd: mobShare.ShareType.MIX_FILE
                  }
                  this.shareType = mobShare.ShareType.MIX_FILE
                  this.butText = "分享图片视频混合"
                }
              })
            Text('图片视频混合').fontSize(16).fontWeight(FontWeight.Bold)
          }.width("33%")
        }.width("100%")

        Button(this.butText)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let type = this.shareType == mobShare.ShareType.VIDEO ? "video" : "image"
            if (this.shareType == mobShare.ShareType.MIX_FILE) {
              type = "mix"
            }
            let finalUri = await Utils.selectMedia(getContext(this), type)
            if (!finalUri) {
              Utils.showMessage(type + "Url is undefined")
            } else {
              if (this.shareType == mobShare.ShareType.IMAGE) {
                this.shareParam.imageUri = finalUri[0]
              } else if (this.shareType == mobShare.ShareType.VIDEO) {
                this.shareParam.videoUri = finalUri[0]
              } else if (this.shareType == mobShare.ShareType.MIX_FILE) {
                this.shareParam.mixFileUris = finalUri
              } else {
                Utils.showMessage("unKnown shareType")
                return
              }
              try {
                this.doShare()
              } catch (e) {
                console.log("e:" + e)
              }
            }
          })
          .margin(10)

        Button("抖音授权")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
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
        Button("抖音获取用户信息")
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
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

        Button("抖音是否授权")
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
            Utils.showMessage("抖音授权：" + await plat.isAuthValid())
          })

        Button("抖音取消授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
            plat.removeAccount()
          })

        Button("抖音是否安装")
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("抖音 Install:" + isInstall)
          })
      }
    }
  }

  async doShare() {
    this.shareParam.title = this.shareTitle
    this.shareParam.shortTitle = this.shortTitle
    if (this.shareParam.shortTitle && this.shareParam.shortTitle != "" && this.shareParam.shortTitle.length > 0) {
      let tags: mobShare.hashTag[] = []
      if (this.tagOne.hashTag != undefined) {
        tags.push(this.tagOne)
      }
      if (this.tagTwo.hashTag != undefined) {
        tags.push(this.tagTwo)
      }
      if (tags.length > 0) {
        this.shareParam.hashTags = tags
      }
    }
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Douyin)
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

  async setDouyinDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的抖音APPKEY")
    map.set(mobShare.Platform_Info.APP_SECRET, "您的抖音APPSECRET")
    map.set(mobShare.Platform_Info.REDIRECT_URL, "您的抖音回调URL")
    map.set(mobShare.Platform_Info.CALLBACK_ABILITY_NAME, "EntryAbility")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.Douyin, map)
  }
}