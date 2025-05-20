import { HashMap } from '@kit.ArkTS'
import mobShare from '@zztsdk/sharesdk'
import { promptAction, SelectDialog } from '@kit.ArkUI'
import { HashonHelper } from '@zztsdk/zztcore'
import { common } from '@kit.AbilityKit'
import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit'
import Utils from '../utils/Utils'
import { image } from '@kit.ImageKit'
import ResourcesManager from '../utils/ResourcesManager'
import { fileIo, fileUri, picker } from '@kit.CoreFileKit'

export const kRoute = "微信"

@Entry({ routeName: kRoute })
@Component
struct wechat {
  @State shareType: string = mobShare.ShareType.TEXT
  @State imageType: string = "imageUrl"
  @State shareText: string = ResourcesManager.text
  @State shareImgUrl: string = ResourcesManager.imgUrl
  @State webPageUrl: string = ResourcesManager.webUrl
  @State videoUrl: string = ResourcesManager.videoUrl
  @State title: string = ResourcesManager.title
  @State des: string = ResourcesManager.description
  @State userName: string = "gh_52568203455c"
  @State path: string = "pages/index/index"
  @State miniprogramType: number = 0
  @State withShareTicket: boolean = false
  @State Scene: number = 0
  scroller: Scroller = new Scroller()
  shareParam: mobShare.SharedParam = {
    utd: mobShare.ShareType.TEXT
  }

  async aboutToAppear() {
    await this.setWechatDevInfo()
    try {
      let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_SIGNATURE_INFO;
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        console.log('getBundleInfoForSelf successfully. Data: ' + JSON.stringify(data))
      }).catch((err: BusinessError) => {
        console.log('getBundleInfoForSelf failed. Cause: ' + err.message);
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      console.log('getBundleInfoForSelf failed: %{public}s', message);
    }
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("分享平台")
          .fontSize(16)
          .margin(10)


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
                  this.shareParam = {
                    utd: mobShare.ShareType.IMAGE
                  }
                  this.shareType = mobShare.ShareType.IMAGE
                }
              })
            Text('图片').fontSize(16).fontWeight(FontWeight.Bold)
          }

          Row() {
            Radio({ value: mobShare.ShareType.WEBPAGE, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享链接")
                  this.shareParam = {
                    utd: mobShare.ShareType.WEBPAGE
                  }
                  this.shareType = mobShare.ShareType.WEBPAGE
                }
              })
            Text('链接').fontSize(16).fontWeight(FontWeight.Bold)
          }

          Row() {
            Radio({ value: mobShare.ShareType.SHARE_WXMINIPROGRAM, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享小程序")
                  this.shareParam = {
                    utd: mobShare.ShareType.SHARE_WXMINIPROGRAM
                  }
                  this.shareType = mobShare.ShareType.SHARE_WXMINIPROGRAM
                }
              })
            Text('分享小程序').fontSize(16).fontWeight(FontWeight.Bold)
          }
        }

        Row() {
          Row() {
            Radio({ value: mobShare.ShareType.FILE, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享文件")
                  this.shareParam = {
                    utd: mobShare.ShareType.FILE
                  }
                  this.shareType = mobShare.ShareType.FILE
                }
              })
            Text('分享文件').fontSize(16).fontWeight(FontWeight.Bold)
          }

          Row() {
            Radio({ value: mobShare.ShareType.VIDEO, group: 'ShareType' })
              .margin(10)
              .checked(false)
              .onChange((isChecked: boolean) => {
                if (isChecked) {
                  this.showMessage("分享视频")
                  this.shareParam = {
                    utd: mobShare.ShareType.VIDEO
                  }
                  this.shareType = mobShare.ShareType.VIDEO
                }
              })
            Text('分享视频').fontSize(16).fontWeight(FontWeight.Bold)
          }
        }

        Text("分享参数")
          .fontSize(16)
          .margin(10)


        Column() {
          TextArea({
            text: this.title,
            placeholder: '输入分享标题',
          }).onChange((value: string) => {
            this.title = value
          }).margin(10)

          TextArea({
            text: this.des,
            placeholder: '输入分享描述',
          }).onChange((value: string) => {
            this.des = value
          }).margin(10)
        }
        .visibility(this.shareType == mobShare.ShareType.WEBPAGE ||
          this.shareType == mobShare.ShareType.VIDEO ||
          this.shareType == mobShare.ShareType.SHARE_WXMINIPROGRAM ? Visibility.Visible : Visibility.None
        )

        Button("分享文件")
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            const documentViewPicker = new picker.DocumentViewPicker(getContext(this));
            const documentSelectOptions = new picker.DocumentSelectOptions();
            documentSelectOptions.maxSelectNumber = 1
            documentViewPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
              //文件选择成功后，返回被选中文档的uri结果集。
              let file = fileIo.openSync(documentSelectResult[0], fileIo.OpenMode.READ_ONLY);
              let tempDir = getContext(this).getApplicationContext().tempDir;
              let fileName = file.name;
              let tmpFile = tempDir + '/' + fileName;
              fileIo.copyFileSync(file.fd, tmpFile)
              let finalUri: string = fileUri.getUriFromPath(tmpFile); // 获取到文件的uri
              this.shareParam.filePathUri = finalUri
              this.doShareWechat()
            }).catch((err: BusinessError) => {
              console.error(`Invoke documentViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
            })
          })
          .margin(10)
          .visibility(this.shareType == mobShare.ShareType.FILE ? Visibility.Visible : Visibility.None)

        Column() {
          TextArea({
            text: this.webPageUrl,
            placeholder: '输入分享链接',
          }).onChange((value: string) => {
            this.webPageUrl = value
          }).margin(10)

          Button("分享链接")
            .fontWeight(FontWeight.Bold)
            .width('95%')
            .onClick(async () => {
              let resourceManager = getContext(this).resourceManager
              let imageArray = await resourceManager.getMediaContent($r("app.media.hhhh"));
              this.shareParam.url = this.webPageUrl
              this.shareParam.title = this.title
              this.shareParam.description = this.des
              this.shareParam.imageData = imageArray;
              this.doShareWechat()
            })
            .margin(10)
        }.visibility(this.shareType == mobShare.ShareType.WEBPAGE ? Visibility.Visible : Visibility.None)


        Column() {
          TextArea({
            text: this.videoUrl,
            placeholder: '输入分享视频链接',
          }).onChange((value: string) => {
            this.videoUrl = value
          }).margin(10)

          Button("分享视频")
            .fontWeight(FontWeight.Bold)
            .width('95%')
            .onClick(async () => {
              let resourceManager = getContext(this).resourceManager
              let imageArray = await resourceManager.getMediaContent($r("app.media.hhhh"));
              this.shareParam.videoUrl = this.videoUrl
              this.shareParam.title = this.title
              this.shareParam.description = this.des
              this.shareParam.imageData = imageArray;
              this.doShareWechat()
            })
            .margin(10)
        }.visibility(this.shareType == mobShare.ShareType.VIDEO ? Visibility.Visible : Visibility.None)


        Column() {
          TextArea({
            text: this.userName,
            placeholder: '输入小程序的原始id',
          }).onChange((value: string) => {
            this.userName = value
          }).margin(10)

          TextArea({
            text: this.path,
            placeholder: '输入小程序页面路径',
          }).onChange((value: string) => {
            this.path = value
          }).margin(10)

          Button("分享微信小程序")
            .fontWeight(FontWeight.Bold)
            .width('95%')
            .onClick(async () => {
              this.shareParam.miniProgramUserName = this.userName
              this.shareParam.miniProgramPath = this.path
              this.shareParam.miniProgramType = this.miniprogramType
              this.shareParam.withShareTicket = this.withShareTicket
              this.shareParam.title = this.title
              this.shareParam.description = this.des

              const thumbData = await getContext(this).resourceManager.getMediaContent($r("app.media.kkk"))
              const thumbPixel = image.createImageSource(thumbData.buffer).createPixelMapSync()
              const thumbBuffer =
                await image.createImagePacker().packing(thumbPixel, { format: "image/jpeg", quality: 50 })
              this.shareParam.imageData = new Uint8Array(thumbBuffer)
              this.doShareWechat()
            })
            .margin(10)
        }.visibility(this.shareType == mobShare.ShareType.SHARE_WXMINIPROGRAM ? Visibility.Visible : Visibility.None)

        Column() {
          Row() {
            Row() {
              Radio({ value: "imageUrl", group: 'imageType' })
                .margin(10)
                .checked(true)
                .onChange((isChecked: boolean) => {
                  this.imageType = "imageUrl"
                })
              Text('网络图片').fontSize(16).fontWeight(FontWeight.Bold)
            }.width("33%")

            Row() {
              Radio({ value: "imagePath", group: 'imageType' })
                .margin(10)
                .checked(false)
                .onChange(async (isChecked: boolean) => {
                  this.imageType = "imagePath"
                })
              Text('本地图片').fontSize(16).fontWeight(FontWeight.Bold)
            }.width("33%")

            Row() {
              Radio({ value: "imageData", group: 'imageType' })
                .margin(10)
                .checked(false)
                .onChange(async (isChecked: boolean) => {
                  this.imageType = "imageData"
                })
              Text('图片(data)').fontSize(16).fontWeight(FontWeight.Bold)
            }.width("33%")
          }


          Column() {
            TextArea({
              text: this.shareImgUrl,
              placeholder: '输入图片链接',
            }).onChange((value: string) => {
              this.shareImgUrl = value
            }).margin(10).visibility(this.imageType == "imageUrl" ? Visibility.Visible : Visibility.None)

            Button("分享网络图片")
              .fontWeight(FontWeight.Bold)
              .width('95%')
              .onClick(async () => {
                this.shareParam.imagePath = undefined
                this.shareParam.imageData = undefined
                this.shareParam.imageUrl = this.shareImgUrl
                this.doShareWechat()
              })
              .margin(10)
              .visibility(this.imageType == "imageUrl" ? Visibility.Visible : Visibility.None)

            Button("分享本地图片")
              .fontWeight(FontWeight.Bold)
              .width('95%')
              .onClick(async () => {
                this.shareParam.imagePath =
                  await Utils.getPictureUriFromAlbum(getContext(this) as common.UIAbilityContext)
                this.shareParam.imageUrl = undefined
                this.shareParam.imageData = undefined
                this.doShareWechat()
              })
              .margin(10)
              .visibility(this.imageType == "imagePath" ? Visibility.Visible : Visibility.None)


            Button("分享图片(data)")
              .fontWeight(FontWeight.Bold)
              .width('95%')
              .onClick(async () => {
                let resourceManager = getContext(this).resourceManager
                let imageArray = await resourceManager.getMediaContent($r("app.media.aaa"));
                this.shareParam.imageData = imageArray;
                this.shareParam.imageUrl = undefined
                this.shareParam.imagePath = undefined
                this.doShareWechat()
              })
              .margin(10)
              .visibility(this.imageType == "imageData" ? Visibility.Visible : Visibility.None)
          }
        }.visibility(this.shareType == mobShare.ShareType.IMAGE ? Visibility.Visible : Visibility.None)

        TextArea({
          text: this.shareText,
          placeholder: '输入分享内容',
        }).onChange((value: string) => {
          this.shareText = value
        }).margin(10)
          .visibility(this.shareType == mobShare.ShareType.TEXT ? Visibility.Visible : Visibility.None)
        Button("分享文本")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(() => {
            this.doShareWechat()
          })
          .visibility(this.shareType == mobShare.ShareType.TEXT ? Visibility.Visible : Visibility.None)

        Button("拉起微信小程序")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(() => {
            let openMiniProgram: mobShare.SharedParam = {
              utd: mobShare.ShareType.OPEN_WXMINIPROGRAM,
              miniProgramPath: "pages/index/index",
              miniProgramUserName: "gh_52568203455c",
              miniProgramType: 0
            }
            let dialog = new CustomDialogController({
              builder: SelectDialog({
                title: '选择小程序',
                selectedIndex: 0,
                confirm: {
                  value: '打开小程序',
                  action: () => {
                    this.openWechatMiniProgram(openMiniProgram)
                    dialog.close()
                  },
                },
                radioContent: [
                  {
                    title: '正式版小程序',
                    action: () => {
                      openMiniProgram.miniProgramType = 0
                    }
                  },
                  {
                    title: '开发版小程序',
                    action: () => {
                      openMiniProgram.miniProgramType = 1
                    }
                  },
                  {
                    title: '体验版小程序',
                    action: () => {
                      openMiniProgram.miniProgramType = 2
                    }
                  },
                ]
              }),
            })
            dialog.open()

          })
        Button("微信授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
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


        Button("微信获取用户信息")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
            let receive: mobShare.PlatformActionListener = {
              onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
                let msg = "showUser onComplete:" + platform.getName() + ",action:" + action + ",map:" +
                HashonHelper.fromMap(res)
                console.log(msg)
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
            mobShare.ShareSDK.getInstance().setUIAbilityContext(getContext(this) as common.UIAbilityContext)
            plat.setPlatformActionListener(receive)
            plat.showUser()
          })

        Button("微信是否授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
            this.showMessage("微信授权：" + await plat.isAuthValid())
          })

        Button("微信取消授权")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
            plat.removeAccount()
          })

        Button("微信是否安装")
          .fontSize(20)
          .margin(10)
          .fontWeight(FontWeight.Bold)
          .width('95%')
          .onClick(async () => {
            let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
            let isInstall = await plat.isClientValid()
            Utils.showMessage("微信 Install:" + isInstall)
          })
      }.alignItems(HorizontalAlign.Start)

    }
  }

  private async setWechatDevInfo(): Promise<boolean> {
    let map = new HashMap<string, Object>()
    map.set(mobShare.Platform_Info.APP_KEY, "您的微信APPKEY")
    map.set(mobShare.Platform_Info.APP_SECRET, "您的微信APPSECRET")
    return mobShare.ShareSDK.getInstance().setPlatformDevInfoAsync(mobShare.Platform.Wechat, map)
  }

  private async doShareWechat() {
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
    let receive: mobShare.PlatformActionListener = {
      onComplete: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>) => {
        let message =
          "share onComplete:" + platform.getName() + ",action:" + action + ",map:" + HashonHelper.fromMap(res)
        console.log(message)
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
    this.shareParam.content = this.shareText
    let records: Array<mobShare.SharedParam> = new Array()
    records.push(this.shareParam)
    plat.setPlatformActionListener(receive)
    plat.share(records, getContext(this) as common.UIAbilityContext)
  }

  private async openWechatMiniProgram(openMiniProgram: mobShare.SharedParam) {
    let plat = await mobShare.ShareSDK.getInstance().getPlatformAsync(mobShare.Platform.Wechat)
    let receive: mobShare.PlatformCommandReceive = {
      onCommandReceive: (platform: mobShare.IPlatform, action: number, res: Map<string, Object>): void => {
        let msg =
          "launchMiniProgram onResp:" + platform.getName() + ",action:" + action + ",map:" + res.get("extMsg")
        console.log(msg)
        this.showMessage(msg)
      }
    }
    let platReceive: mobShare.PlatformActionListener = {
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
    plat.setPlatformActionListener(platReceive)
    let records: Array<mobShare.SharedParam> = new Array()
    records.push(openMiniProgram)
    plat.setCommandReceive(receive)
    plat.share(records, getContext(this) as common.UIAbilityContext)
  }

  showMessage(message:
    string
  ) {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}