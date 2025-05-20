import { ZztSDK } from '@zztsdk/zztcore';
import { router } from '@kit.ArkUI';

import { kRoute as douyin } from './douyin';
import { kRoute as huawei } from './huawei';
import { kRoute as qq } from './qq';
import { kRoute as SinaWeibo } from './SinaWeibo';
import { kRoute as wechat } from './wechat';
import { kRoute as alipay } from './alipay';
import { kRoute as KuaiShou } from './kuaiShou'
import { kRoute as DingDing } from './dingding'
import { kRoute as KnockShare } from './KnockShare'
import { kRoute as lark } from './lark'
@Entry
@Component
struct Index {
  scroller: Scroller = new Scroller()
  private menuList: Array<string> = [huawei, SinaWeibo, wechat, qq, alipay, douyin, KuaiShou, DingDing, KnockShare,lark]

  build() {
    Scroll(this.scroller) {
      Column() {
        Text("ShareSDK DEMO")
          .width('100%')
          .margin(10)
          .align(Alignment.Center)
          .textAlign(TextAlign.Center)
        Button("初始化")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            ZztSDK.init(getContext(this), "moba0b0c0d0", "5713f0d88511f9f4cf100cade0610a34")
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("同意隐私")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            ZztSDK.submitPolicyGrantResult(true)
          })
          .width('90%')
          .margin(10)
          .padding(15)

        Button("拒绝隐私")
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            ZztSDK.submitPolicyGrantResult(false)
          })
          .width('90%')
          .margin(10)
          .padding(15)

        List({ space: 10 }) {
          ForEach(this.menuList, (item: string) => {
            ListItem() {
              Row() {
                Button(item)
                  .fontWeight(FontWeight.Bold)
                  .width('100%')
                  .padding(15)
                  .onClick(() => {
                    router.pushNamedRoute({ name: item })
                  })
              }
              .justifyContent(FlexAlign.Center)
            }
          })
        }
        .width('90%')
        .height('100%')
        .margin(10)

      }
      .width('100%')
    }
    .height('100%')
    .align(Alignment.Top)
  }
}