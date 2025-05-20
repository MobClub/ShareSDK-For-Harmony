import common from '@ohos.app.ability.common';
import mobShare from '@zztsdk/sharesdk';
import { ArrayList, HashMap } from '@kit.ArkTS';
import { HashonHelper } from '@zztsdk/zztcore';
import { promptAction } from '@kit.ArkUI';
import picker from '@ohos.file.picker';
import { BusinessError } from '@ohos.base';
import { fileUri } from '@kit.CoreFileKit';
import Utils from '../utils/Utils';

export const kRoute = "新浪微博"

@Entry({ routeName: kRoute })
@Component
struct SinaWeibo {
  photoSelectOptions = new picker.PhotoSelectOptions();
  context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  @State shareType: string = mobShare.ShareType.TEXT
  scroller: Scroller = new Scroller()
  isInit: boolean = false;
  shareText: string | undefined = undefined
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.TEXT
  }

  async aboutToAppear() {
    this.copyFile()
    await this.setWeiBoDevInfo()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("分享内容类型")
          .fontSize(16)
          .margin(10)
        Row() {
          Row() {
            Radio({ value: mobShare.ShareType.TEXT, group: 'ShareType' })
              .margin(10)
              .checked(true)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享文本")
                  this.shareParam = {
                    utd: mobShare.ShareType.TEXT
                  }
                  this.shareType = mobShare.ShareType.TEXT
                }
              })
            Text('文本').fontSize(16).fontWeight(FontWeight.Bold)
          }

          Row() {
            Radio({ value: mobShare.ShareType.IMAGE, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享图片")
                  let uris = new ArrayList<string>();
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/aaa.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/bbb.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/ccc.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/ddd.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/eee.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/fff.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/ggg.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/hhhh.png"));
                  uris.add(fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + "/kkk.png"));
                  let imgurl = uris.convertToArray();
                  this.shareParam = {
                    utd: mobShare.ShareType.IMAGE,
                    imageUris: imgurl
                  }
                  this.shareType = mobShare.ShareType.IMAGE
                }
              })
            Text('图片').fontSize(16).fontWeight(FontWeight.Bold)
          }

          Row() {
            Radio({ value: mobShare.ShareType.VIDEO, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享视频")
                  let videoFilePath = Utils.getVideoCacheFile(getContext()) + '/eeee.mp4';
                  let videoUri = fileUri.getUriFromPath(videoFilePath);
                  let coverUri = fileUri.getUriFromPath(Utils.getImageCacheFile(getContext()) + '/cover.png');
                  this.shareParam = {
                    utd: mobShare.ShareType.VIDEO,
                    videoUri: videoUri,
                    videoCoverUri: coverUri
                  }
                  this.shareType = mobShare.ShareType.VIDEO
                }
              })
            Text('视频').fontSize(16).fontWeight(FontWeight.Bold)
          }
        }

        Text("分享参数")
          .fontSize(16)
          .margin(10)

        Column() {
          TextArea({
            placeholder: '输入分享参数',
          }).onChange((value: string) => {
            if (value == "") {
              this.showMessage("请输入分享文字内容")
              return
            }
            this.shareText = value
          }).margin(10)
        }

        Column() {
          Text("选择本地图片")
            .fontSize(16)
            .margin(10)
          Button("选择本地图片")
            .fontSize(20)
            .margin(10)
            .fontWeight(FontWeight.Bold)
            .width('95%')
            .onClick(() => {
              this.photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_TYPE; // 过滤选择媒体文件类型为IMAGE
              this.photoSelectOptions.maxSelectNumber = 9; // 选择媒体文件的最大数目
              let uris: Array<string> = [];
              const photoViewPicker = new picker.PhotoViewPicker();
              photoViewPicker.select(this.photoSelectOptions).then((photoSelectResult: picker.PhotoSelectResult) => {
                uris = photoSelectResult.photoUris;
                console.info('photoViewPicker.select to file succeed and uris are:' + uris);
                this.shareParam.utd = mobShare.ShareType.IMAGE
                this.shareParam.imageUris = uris
              }).catch((err: BusinessError) => {
                console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
              })
            })

        }.visibility(Visibility.None)

        Column() {
          Text("选择视频和视频封面图片")
            .fontSize(16)
            .margin(10)
          Text("注意：先选择视频后选择封面图片")
            .fontSize(16)
            .margin(10)
          Button("选择本地视频和视频封面图片")
            .fontSize(20)
            .margin(10)
            .fontWeight(FontWeight.Bold)
            .width('95%')
            .onClick(() => {
              this.photoSelectOptions.MIMEType = picker.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE; // 过滤选择媒体文件类型为IMAGE
              this.photoSelectOptions.maxSelectNumber = 2; // 选择媒体文件的最大数目
              let uris: Array<string> = [];
              const photoViewPicker = new picker.PhotoViewPicker();
              photoViewPicker.select(this.photoSelectOptions).then((photoSelectResult: picker.PhotoSelectResult) => {
                uris = photoSelectResult.photoUris;
                console.info('photoViewPicker.select to file succeed and uris are:' + uris);
                this.shareParam.utd = mobShare.ShareType.VIDEO
                this.shareParam.videoUri = uris[0]
                this.shareParam.videoCoverUri = uris[1]
              }).catch((err: BusinessError) => {
                console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
              })
            })
        }.visibility(Visibility.None)


        Button("分享")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SinaWeibo)
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
            if (this.shareText) {
              this.shareParam.content = this.shareText
            }
            let records: Array<mobShare.SharedParam> = new Array()
            records.push(this.shareParam)
            plat.setPlatformActionListener(receive)
            plat.share(records, getContext(this) as common.UIAbilityContext)
          })
        Button("微博授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SinaWeibo)
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
            plat.setPlatformActionListener(receive)
            plat.authorize()
          })

        Button("微博获取用户信息")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SinaWeibo)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                console.log(msg)
                promptAction.showToast({
                  message: msg,
                  duration: 2000,
                  bottom: 10
                });
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
            mobShare.ShareSDK.getInstance().setUIAbilityContext(getContext(this) as common.UIAbilityContext)
            plat.setPlatformActionListener(receive)
            plat.showUser()
          })

        Button("微博是否授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SinaWeibo)
            this.showMessage("微博授权：" + await plat.isAuthValid())
          })

        Button("微博取消授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.SinaWeibo)
            plat.removeAccount()
          })
      }.alignItems(HorizontalAlign.Start)
    }
  }

  private async setWeiBoDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的微博APPKEY")
    map.set(mobShare.Platform_Info.REDIRECT_URL, "您的微博回调URL")
    map.set(mobShare.Platform_Info.CALLBACK_ABILITY_NAME, "EntryAbility")
    return await mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.SinaWeibo, map)
  }

  copyFile() {
    Utils.saveImageFile(getContext(), 'aaa.png', $r('app.media.aaa'));
    Utils.saveImageFile(getContext(), 'bbb.png', $r('app.media.bbb'));
    Utils.saveImageFile(getContext(), 'ccc.png', $r('app.media.ccc'));
    Utils.saveImageFile(getContext(), 'ddd.png', $r('app.media.ddd'));
    Utils.saveImageFile(getContext(), 'eee.png', $r('app.media.eee'));
    Utils.saveImageFile(getContext(), 'fff.png', $r('app.media.fff'));
    Utils.saveImageFile(getContext(), 'ggg.png', $r('app.media.ggg'));
    Utils.saveImageFile(getContext(), 'hhhh.png', $r('app.media.hhhh'));
    Utils.saveImageFile(getContext(), 'kkk.png', $r('app.media.kkk'));
    Utils.saveImageFile(getContext(), 'cover.png', $r('app.media.cover'));
    Utils.saveVideoFile(getContext(), 'eeee.mp4', $r('app.media.eeee'))
  }

  showMessage(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}