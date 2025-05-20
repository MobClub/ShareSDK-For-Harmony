import mobShare from "@zztsdk/sharesdk"
import { fileUri } from "@kit.CoreFileKit"
import ResourcesManager from "../utils/ResourcesManager";
import Utils from "../utils/Utils";

export const kRoute = "碰一碰分享"

@Entry({ routeName: kRoute })
@Component
struct knockShare {
  @State shareParamType: number = 1
  @State images: boolean = false
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.IMAGE
  }

  aboutToAppear() {
    this.copyFile()
  }

  build() {
    Column() {
      Text("分享内容类型")
        .fontSize(16)
        .margin(10)
      Column() {
        Row() {
          Radio({ value: mobShare.ShareType.IMAGE, group: 'ShareType' })
            .margin(10)
            .checked(true)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.shareParamType = 1
              }
            })
          Text('纯图片布局').fontSize(16).fontWeight(FontWeight.Bold)

          Radio({ value: "images", group: 'imageCount' })
            .margin(10)
            .checked(false)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.images = true
              }
            })
          Text('多图').fontSize(16).fontWeight(FontWeight.Bold)
        }.width("33%")

        Row() {
          Radio({ value: mobShare.ShareType.VIDEO, group: 'ShareType' })
            .margin(10)
            .checked(false)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                this.shareParamType = 2
              }
            })
          Text('沉浸式大卡布局').fontSize(16).fontWeight(FontWeight.Bold)
        }.width("33%")


        Row() {
          Radio({ value: mobShare.ShareType.MIX_FILE, group: 'ShareType' })
            .margin(10)
            .checked(false)
            .onChange((isChecked: boolean) => {
              if (isChecked) {
                if (isChecked) {
                  this.shareParamType = 3
                }
              }
            })
          Text('白卡上下布局').fontSize(16).fontWeight(FontWeight.Bold)
        }.width("33%")
      }.width("100%")

      Button("注册碰一碰分享")
        .fontSize(20)
        .margin(10)
        .fontWeight(FontWeight.Bold)
        .width('95%')
        .onClick(() => {
          let receive: mobShare.onKnockShareListener = {
            onKnockShare: (): mobShare.SharedParam[] => {
              let filePath = fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/fff.png")
              if (this.shareParamType == 1) {
                this.shareParam.utd = mobShare.ShareType.IMAGE
                this.shareParam.uri = filePath
              } else {
                if (this.shareParamType == 3) {
                  filePath = fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/bbb.png")
                }
                this.shareParam.utd = mobShare.ShareType.HYPERLINK
                this.shareParam.content = ResourcesManager.webUrl
                this.shareParam.thumbnailUri = filePath
                this.shareParam.title = ResourcesManager.title
                this.shareParam.description = ResourcesManager.description
              }
              let records: Array<mobShare.SharedParam> = new Array()
              records.push(this.shareParam)
              if (this.shareParamType == 1 && this.images) {
                records.push({
                  utd: mobShare.ShareType.IMAGE,
                  uri: fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/bbb.png")
                })
              }
              return records
            },
            onError: (error: Error) => {
              let message = "registerKnockShare onError:" + error.message
              Utils.showMessage(message)
            }
          }
          mobShare.ShareSDK.getInstance().registerKnockShare(receive)
        })

      Button("取消注册碰一碰分享")
        .fontSize(20)
        .margin(10)
        .fontWeight(FontWeight.Bold)
        .width('95%')
        .onClick(() => {
          mobShare.ShareSDK.getInstance().unRegisterKnockShare()
        })
    }
  }

  copyFile() {
    Utils.saveImageFile(getContext(), 'bbb.png', $r('app.media.bbb'));
    Utils.saveImageFile(getContext(), 'fff.png', $r('app.media.fff'));
  }
}