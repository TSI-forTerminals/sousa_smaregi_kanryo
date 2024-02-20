//
//  ContentView.swift
//  smaregi_kanryo_sousa
//
//  Created by 城川一理 on 2021/08/07.
//

import SwiftUI

import Network //20210826

//UserDefaultsの処理をまとめたクラス
//別ファイルにまとめるべき？
class UserProfile: ObservableObject {
    //精算画面様端末のアドレス
    @Published var changerappip: String{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(changerappip, forKey: "changerappip")
        }
    }
    //釣銭機端末のアドレス
    @Published var changerip: String{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(changerip, forKey: "changerip")
        }
    }
    //釣銭機端末のポート番号
    @Published var changerport: String{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(changerport, forKey: "changerport")
        }
    }
    //<Add 20211013 V1.9>
    //釣銭機端末のポート番号
    @Published var closingsleep: String{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(closingsleep, forKey: "closingsleep")
        }
    }
    //</Add 20211013 V1.9>
    //<Add 20211111 V1.16>
    //ログ書き出しのオンオフ
    @Published var loguse: Bool{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(loguse, forKey: "loguse")
        }
    }
    //</Add 20211111 V1.16>
    //<Add 20220507 V1.30>
    //投入金額読取時間制限
    @Published var keisureadtimelimit: String{
        didSet{
            //プロパティ設定領域への保存
            UserDefaults.standard.set(keisureadtimelimit, forKey: "keisureadtimelimit")
        }
    }
    //</Add 20220507 V1.30>
    //初期化処理
    init() {
        //プロパティ設定領域からの呼び出し
        changerappip = UserDefaults.standard.string(forKey: "changerappip") ?? ""
        changerip = UserDefaults.standard.string(forKey: "changerip") ?? ""
        changerport = UserDefaults.standard.string(forKey: "changerport") ?? ""
        //<Add 20211013 V1.9>
        closingsleep = UserDefaults.standard.string(forKey: "closingsleep") ?? ""
        //</Add 20211013 V1.9>
        //<Add 20211111 V1.16>
        loguse = UserDefaults.standard.bool(forKey: "loguse")
        //</Add 20211111 V1.16>
        //<Add 20220507 V1.30>
        keisureadtimelimit = UserDefaults.standard.string(forKey: "keisureadtimelimit") ?? ""
        //</Add 20220507 V1.30>
    }
}

struct ContentView: View {
    @State var operation: String = ""
    @State var callback: String = ""
    @State var slipnumber: String = ""
    @State var price: String = ""
    @State var transaction: String = ""
    @State var chanerappip: String = ""
    @State var reply: String = "" //スマレジアプリに返却する値
    @State var chargerrep: String = "" //実行結果 //釣り銭機からの返信
    @State var deposit: String = "" //投入金額
    @State var charge: String = "" //おつり
    
    @State var annaunce: String = "" //案内
    
    //<Add 20211011 V1.9>
    @State var jimucan: String = ""//事務側精算のキャンセル
    @State var jimuseisan: String = ""//事務側精算の確定
    @State var closettl: String = "強制終了"//投入金を排出して釣り銭機計数停止後このアプリを閉じる
    @State var tsusinttl: String = "通信確認"
    @State var canloop: Bool = true //<Add 2021011 V1.9>
    @State var canstate: Int = 0 //<Add 20211011 V1.9>
    @State var customercode: String = ""
    @State var customername: String = ""
    @State var billingamount: String = ""
    //</Add 20211011 V1.9>
    
    //<Add 20211017 V1.10>
    @State var confirmstatus: String = "0"
    //@State var blnKeisureaderr: Bool = false
    // 状態オブジェクトの型
    struct AlertItem: Identifiable {
        var id = UUID()
        var alert: Alert
    }
    @State private var showingAlert: AlertItem?
    //</Add 20211017 V1.10>
    
    //@State var blnPriceerr: Bool = false
    
    //<Add 20220329 V1.30>
    @Environment(\.scenePhase) private var senePhase
    //</Add 20220329 V1.30>

    @ObservedObject var profile = UserProfile()
    
    var closingsleep: Double = Double(UserDefaults.standard.string(forKey: "closingsleep") ?? "1.0") ?? 1.0//<Add 20211013 V1.9>
    var keisureadtimelimit: Int = Int(UserDefaults.standard.string(forKey: "keisureadtimelimit") ?? "7") ?? 7//<Add 20220507 V1.30>

    var body: some View {
        NavigationView {
            //背景色の設定 スマレジ背景色規定 #0087e6
            ZStack {
                Color(red: 0, green: 0.95, blue: 0, opacity: 0.2)
                    .edgesIgnoringSafeArea(.all)
                VStack{
                    Text("スマレジ金額送信")
                        .font(.title)
                    Text("患者様が金額を投入中です。")
                        .font(.largeTitle)
                    Text("")
                        .font(.body)
                    Text("ホームボタンを押したり、他のアプリに\n切り替えたりしないで下さい。")
                        .font(.body)
                    //<Add 20210914 ver1.5>
                    Text("")
                        .font(.body)
                    //<Add 20211014 ver1.9>
                    VStack{ //<Add 20211018 ver1.10 />
                        Text(customercode)
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                            .padding()
                        Text(customername + " 様")
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                            .padding()
                        Text("ご請求 " + getComma(num: billingamount))
                            .font(.system(size: 50, weight: .black, design: .default))
                            .foregroundColor(Color.black)
                            .padding()
                            .frame(width: 600.0)
                        Text("投入金額　" + getComma(num: deposit))
                            .font(.largeTitle)
                            .foregroundColor(Color.black)
                            .padding()
                            .frame(width: 500.0)
                        Text("おつり　" + getComma(num: charge))
                            .font(.system(size: 50, weight: .black, design: .default))
                            .foregroundColor(Color.black)
                            .padding()
                            .frame(width: 600.0)
                        //</Add 20211014 ver1.9>
                        
                        //<Add 20211203 おつり不足表示 ver1.20>
                        Text(annaunce)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color.red)
                            .padding()
                        //</Add 20211203 おつり不足表示 ver1.20>
                        
                        //<Add 20211018 ver1.10>
                        Button( action:
                                    {
                            jimugawaseisan()
                        })
                        {
                            Text(jimuseisan)
                                .font(Font.system(size: 48).bold())
                            /*.frame(width: 550.0, height: 65.0)
                             .background(Color.white) */
                        }
                        .disabled(confirmstatus != "1")
                        //</Add 20211018 ver1.10>
                    }
                }
            }
            .navigationBarTitle("スマレジ金額送信", displayMode: .inline)
            .navigationBarItems(leading:
                                    HStack{
                //<Add 20210930 ver1.9>
                Button(action: {
                    jimucancel()
                }, label: {
                    Text(jimucan)
                })
                Button(action: {
                    //<Del 20211030 V1.12> アラートで出金するか切り分けるべきなので無効化する
                    //                    //keisuendまでしていた投入金は精算済みとみなし、keisustartによりクリアする
                    //                    chargerrep = Subformview.keisustart_telegram_get(host: profile.changerip, port: profile.changerport)
                    //                    Thread.sleep(forTimeInterval: 0.2)//各teregramの間にスリープを設ける
                    //< /Del 20211030 V1.12> 釣銭出力をループを抜けた後に移動
                    //投入金額を取得して返金する。釣り銭機の計数状態を停止する。
                    let irtn = emergencyend(paytype: 3)
                    if irtn < 10 {
                        exit(0)
                    } else if (irtn == 94){
                        //投入金の残高排出に失敗したらメッセージを表示
                        showingAlert = AlertItem(alert: Alert(title: Text("特定金種の残高不足による出金失敗"), message: Text(deposit + "円の出金が出来ませんでした。この金額をお控えの上、手動で返金の処置をお願い致します。"), dismissButton: .cancel(Text("OK"),action: {
                            ResetKeisubuff()
                            exit(0) })))
                    }
                }, label: {
                    Text(closettl)
                })
                //</Add 20210930 ver1.9>
            }, trailing: HStack{
                //<Add 20210927 V1.8?>
                Button(action: {
                    chargerrep = ResetdispRtn()
                    Thread.sleep(forTimeInterval: 1)
                    exit(0)//ホームボタンの使用回避の為、自動終了させる
                }, label: {
                    Text(tsusinttl)
                })
                //</Add 20210927 V1.8?>
                NavigationLink(
                    destination: Subformview()){
                        Text("　設 定　")
                    }
            })
            //遷移先の画面で遷移元の画面の関数を呼ぶ仕組み②　SettingView(delegate: self)の部分
        }
        .navigationViewStyle(StackNavigationViewStyle())// iPhoneとiPadの見え方を同じにする
        //<Add 20211020 V1.10>
        .alert(item: $showingAlert){ item in
            item.alert
        }
        //</Add 20211020 V1.10>
        //<Add 20220329 V1.30>
        .onChange(of: senePhase){ phase in
            if phase == .background{
                print("background")
                TSILog.write("background",funcnm: #function,line: #line, loguse: profile.loguse)
                exit(0)
            }
            if phase == .inactive {
                print("inactive")
            }
        }
        //</Add 20220329 V1.30>
        .onOpenURL(perform: { url in
            //DispatchQueue.main.async {
            closettl = ""
            jimucan = "精算のキャンセル"
            jimuseisan = "精算の確定"
            tsusinttl = ""
            //}
            //onOpenURLがうまく起動しないときは、精算ループの後ろにしてみる？

            //<Add 20220228 ログ書き出し V1.28>
            var logprm = "起動直後->url:" + url.description
            TSILog.write(logprm, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20220228 ログ書き出し V1.28>

            //スマレジアプリから起動された時のクエリパラメータの書出し
            let urlcomponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            let lidx = urlcomponents?.queryItems?.count ?? 0
            var idx = 0
            while idx < lidx {
                let itm = urlcomponents?.queryItems?[idx]
                let nm = itm?.name
                if nm == "operation" {
                    operation = itm?.value ?? ""
                }
                if nm == "callback" {
                    callback = itm?.value ?? ""
                }
                if nm == "slipNumber" {
                    slipnumber = itm?.value ?? ""
                }
                if nm == "price" {
                    price = itm?.value ?? ""
                }
                if nm == "transaction" {
                    transaction = itm?.value ?? ""
                }
                idx += 1
            }
            reply = ""

            //<Add 20210924 V1.8>
            if price == "" {
                //blnPriceerr = true//アラートの表示
                showingAlert = AlertItem(alert: Alert(title: Text("請求額取得エラー"), message: Text("請求額を取得出来ませんでした。"), dismissButton: .cancel(Text("OK"), action: {
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "請求額の取得エラーによりキャンセルされました。", slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep)
                    exit(0)
                })))
                return
            }
            //</Add 20210924 V1.8>
            
            //<Add 20220228 ログ書き出し V1.28>
            logprm = "請求額の取得エラー回避->price:" + price
            TSILog.write(logprm, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20220228 ログ書き出し V1.28>

            //<Add 20210831　取引履歴取引>
            if (operation != "pay"){
                henkin()
                Thread.sleep(forTimeInterval: closingsleep)//2->1
                exit(0)
                //return exitされる為不要
            }
            //</Add 20210831>
            
            //<Add 20211014 事務側精算 V1.9>
            let tranString: String = transaction
            let tranData: Data =  tranString.data(using: String.Encoding.utf8)!
            do {
                // パースする
                let hditems = try JSONSerialization.jsonObject(with: tranData) as! Dictionary<String, Any>
                let heads: Dictionary<String, Any> = hditems["transactionHead"] as! Dictionary<String, Any>
                customercode = heads["customerCode"] as? String ?? ""
                customername = heads["customerName"] as? String ?? ""
            } catch {
                print(error)
            }
            billingamount = price
            //</Add 20211014 事務側精算 V1.9>
            
            //<Add 20211111 ログ書き出し V1.16>
            let logpara = "起動時->会員番号:" + customercode + " 氏名:" + customername + " 請求額:" + price
            TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20211111 ログ書き出し V1.16>
            
            //<Add 20210930 事務側キャンセル V1.9>
            let globalq = DispatchQueue.global()
            globalq.async() { //20211008
                //<Upd 20210914 ver1.5>
                //let iRtn = seisan()
                let iRtn = seisan2()
                //</Upd 20210914 ver1.5>
                if (iRtn == 0){
                    //<Add 20220330 CallSmaregiの前に移動 ver1.30>
                    chargerrep = ResetdispRtn()
                    //</Add 20220330 CallSmaregiの前に移動 ver1.30>
                    //<Add 20211101 ver1.12> seisan2から移動
                    reply = CallSmaregi(smcallback: callback, rslt: "1", miss: "", slip: slipnumber, prc: price)
                    //</Add 20211101 ver1.12>
                    
                    //スリープさせてからexitしないとスマレジ・アプリに遷移しない
                    //exitしないと次に起動された時に落ちる
                    Thread.sleep(forTimeInterval: closingsleep) //2->1 2以上だとexitが度々無効になるので1に変更した20211012
                    TSILog.write("sleepEnd",funcnm: #function,line: #line, loguse: true)
                    exit(0)
                }else if (iRtn == 1){
                    //<Add 20220330 CallSmaregiの前に移動 ver1.30>
                    chargerrep = ResetdispRtn()
                    //</Add 20220330 CallSmaregiの前に移動 ver1.30>
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "お客様からキャンセルされました。", slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep) //2->1
                    exit(0)
                    //<Add 20210930 事務側キャンセル V1.9>
                }else if (iRtn == 2){
                    //事務側からのキャンセル処理
                    //</Add 20210930 事務側キャンセル V1.9>
                }
                //<Add 20211102 V1.12>
                //前の人のお金の取り出しが終わるのを待つ対処。現状は終了を待っているので起こり得ない。もし起こった場合、問題なければ強制終了で対処する
                else if (iRtn == 90){
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "前のお客様の操作が完了していない等によりキャンセルしました。", slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep)//2->1
                    exit(0)
                }
                //<Add 20211102 V1.12>
                //<Add 20211104 V1.12>
                else if (iRtn == 94){
                    //投入金の残高排出に失敗したらメッセージを表示
                    showingAlert = AlertItem(alert: Alert(title: Text("特定金種の残高不足による出金失敗"), message: Text(deposit + "円の出金が出来ませんでした。この金額をお控えの上、手動で返金の処置をお願い致します。"), dismissButton: .cancel(Text("OK"),action: {
                        ResetKeisubuff()
                        //<Add 20220330 CallSmaregiの前に移動 ver1.30>
                        chargerrep = ResetdispRtn()
                        //</Add 20220330 CallSmaregiの前に移動 ver1.30>
                        reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "患者側からキャンセルされました。", slip: slipnumber, prc: price)
                        Thread.sleep(forTimeInterval: closingsleep)//2->1
                        exit(0) })))
                }
                //</Add 20211104 V1.12>
                //<Add 20220511 V1.30>
                else if (iRtn == 97){
                    chargerrep = ResetdispRtn()
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "釣り銭機との通信速度が遅い為、精算を中止しました。釣り銭機の再起動が有効です。エラーコード:" + String(iRtn), slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep)
                    exit(0)
                }
                //</Add 20220511 V1.30>
                else {
                    //<Add 20220330 CallSmaregiの前に移動 ver1.30>
                    chargerrep = ResetdispRtn()
                    //</Add 20220330 CallSmaregiの前に移動 ver1.30>
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "釣銭機との通信異常等によりキャンセルしました。エラーコード:" + String(iRtn), slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep)//2->1
                    exit(0)
                }
            } //globalq.async
            
        })//onOPenURL
        
    }
    //<Add 20211010 ver1.9>
    //「精算のキャンセル」をタップした時の処理
    func jimucancel(){
        
        self.canloop = false//20211008 onOpenURLからの非同期処理を中止する
        self.canstate = 0
        var iWaitcnt: Int = 0
        while canstate == 0 {
            //seisan2でcanstateが変わるのを待つ
            Thread.sleep(forTimeInterval: 0.1)
            //onOpenURLのスレッド停止に3秒以上掛かったら中止
            iWaitcnt += 1
            if iWaitcnt > 30 {
                return //メッセージを表示する？
            }
        }
        annaunce = "事務側の指示により精算をキャンセルします。"
        chargerrep = ConfsetRtn(confirmstatus: "4", announce: annaunce)
        Thread.sleep(forTimeInterval: 0.5)
        
        let iRtn = emergencyend(paytype: 3)
        
        if iRtn < 10 {
            //<Add 20220330 CallSmaregiの前に移動 ver1.30>
            chargerrep = ResetdispRtn()
            //</Add 20220330 CallSmaregiの前に移動 ver1.30>
            reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "事務側からキャンセルされました。", slip: slipnumber, prc: price)
            Thread.sleep(forTimeInterval: closingsleep)//2->1
            exit(0)
        }
        //<Add 20211104 V1.12>
        else if (iRtn == 94){
            //投入金の残高排出に失敗したらメッセージを表示
            showingAlert = AlertItem(alert: Alert(title: Text("特定金種の残高不足による出金失敗"), message: Text(deposit + "円の出金が出来ませんでした。この金額をお控えの上、手動で返金の処置をお願い致します。"), dismissButton: .cancel(Text("OK"),action: {
                ResetKeisubuff()
                //<Add 20220330 CallSmaregiの前に移動 ver1.30>
                chargerrep = ResetdispRtn()
                //</Add 20220330 CallSmaregiの前に移動 ver1.30>
                reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "事務側からキャンセルされました。", slip: slipnumber, prc: price)
                Thread.sleep(forTimeInterval: closingsleep)//2->1
                exit(0) })))
        }
        //</Add 20211104 V1.12>
        
    } //jimucancel()
    
    //事務側で精算ボタンを押した時の処理
    func jimugawaseisan(){
        
        self.canloop = false//20211008 onOpenURLからの非同期処理を中止する
        self.canstate = 0
        var iWaitcnt = 0
        while canstate == 0 {
            //seisan2でcanstateが変わるのを待つ
            Thread.sleep(forTimeInterval: 0.1)
            //onOpenURLのスレッド停止に3秒以上掛かったら中止
            iWaitcnt += 1
            if iWaitcnt > 30 {
                return //メッセージを表示する？
            }
        }
        annaunce = "事務側の指示により精算を完了します。"
        chargerrep = ConfsetRtn(confirmstatus: "2", announce: annaunce)
        Thread.sleep(forTimeInterval: 0.5)
        
        let iRtn = emergencyend(paytype: 2)
        
        if iRtn < 10 {
            //<Add 20220330 CallSmaregiの前に移動 ver1.30>
            chargerrep = ResetdispRtn()
            //</Add 20220330 CallSmaregiの前に移動 ver1.30>
            reply = CallSmaregi(smcallback: callback, rslt: "1", miss: "", slip: slipnumber, prc: price)
            Thread.sleep(forTimeInterval: closingsleep)//2->1
            exit(0)
        }
    }
    //</Add 20211010 ver1.9>
    
    //<Add 20210914 ver1.5>
    //金額表示端末への一連の処理
    //精算ボタン押下後に計数停止
    func seisan2() -> Int {
        var strRead: String = "" //<Add 20211118 V1.17>
        var iRtn: Int = 90
        //1let queue = DispatchQueue(label: "work.tsirelay.dispatch_queue_serial")
        let iPrice: Int = Int(price) ?? 0 //請求額
        var iDeposit:Int = 0
        var blnCan: Bool = false
        //スマレジアプリから精算金額（と会員番号・氏名）を取得し、
        //請求額を表示用iPadに送る。釣り銭機は金銭投入待ち状態に移行
        let tranString: String = transaction
        let tranData: Data =  tranString.data(using: String.Encoding.utf8)!
        var strPtnum: String = ""
        var strPtname: String = ""
        do {
            // パースする
            let hditems = try JSONSerialization.jsonObject(with: tranData) as! Dictionary<String, Any>
            let heads: Dictionary<String, Any> = hditems["transactionHead"] as! Dictionary<String, Any>
            strPtnum = heads["customerCode"] as? String ?? ""
            strPtname = heads["customerName"] as? String ?? ""
        } catch {
            print(error)
            //<Add 20220228 ログ書き出し V1.28>
            let logprm = "seisan2請求データパースエラー" + error.localizedDescription
            TSILog.write(logprm, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20220228 ログ書き出し V1.28>
        }
        //<Add 20211102 V1.12>
        //釣り銭機が前の患者の処理中なら待つ処理
        var blnLp = true
        var iCnt:Int = 0
        while blnLp {
            let strSt = Subformview.enq_telegram_get(host: profile.changerip, port: profile.changerport)
            //<Upd 20220308 ログ書き出し V1.29>
            //NSLog("enqstate:\(strSt)")
            let logprm = "enqstate->" + strSt + " iCnt:" + iCnt.description
            TSILog.write(logprm, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Upd 20220308 ログ書き出し V1.29>
            //"DC2"(抜取り待ち),"DC4"(放出可動作中),"SUB"(動作中)
            if (strSt == "DC2" || strSt == "DC4" || strSt == "SUB") { //"EM"(計数停止中)"SOH"(計数中)も加える？
                Thread.sleep(forTimeInterval: 0.5)// 釣り銭放出した時のための待ち
                iCnt = iCnt + 1
                if iCnt > 5 {
                    blnLp = false
                }
            }else{
                blnLp = false
            }
        }
        //３(0.5:6)秒待っても終わらなければ、一旦キャンセル処理する
        if iCnt > 5 {
            iRtn = 90
            return iRtn
        }
        //</Add 20211102 V1.12>
        
        //<Add 20220228 ログ書き出し V1.28>
        var logpara = "計数スタート送信前->会員番号:" + strPtnum + " 氏名:" + strPtname + " 請求額:" + price
        TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
        //</Add 20220228 ログ書き出し V1.28>
        chargerrep = KeisuStartonRtn(price: price, customercode: strPtnum, customername: strPtname)
        //<Add 20220228 ログ書き出し V1.28>
        logpara = "計数スタート送信後" + chargerrep
        TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
        //</Add 20220228 ログ書き出し V1.28>

        //<Add 20211108 V1.14>
        var iCnter:Int = 0
        let iErlmt: Int = 20
        //</Add 20211108 V1.14>
        //取消ボタンが押されるか、精算ボタンが押されるまで投入金額の計数を繰り返す
        var strStopcd: String = "" //確認ボタンの状態　0:有効化前 1:有効状態 2:確認状態 3:取消押下 4:事務側取消(Add210930)
        var blnBrk: Bool = false
        //1let semaphore = DispatchSemaphore(value: 0)
        var sendmes: String = ""
        var strKeisu: String = ""//キャンセル時の返金用
        while (blnCan == false && blnBrk == false) {
            //<Add 20211010 ver1.9>
            if !canloop {
                canstate = 1
                return 2 //seisan2を抜ける
            }
            //</Add 20211010 ver1.9>
            //1queue.async {
            //投入金額を取得する
            //<Add 20220421 計数時間超過対応 ver1.30>
            let dblReadStart = Double(Date().timeIntervalSince1970)
            //</Add 20220421 計数時間超過対応 ver1.30>

            chargerrep = KeisuReadRtn()

            //</Add 20220421 計数時間超過対応 ver1.30>
            //計数リードに５秒以上掛かったらログに残す
            let dblNow = Double(Date().timeIntervalSince1970)
            let time = Int(dblNow - dblReadStart)
            if time >= keisureadtimelimit {
                TSILog.write("keisuread timeover",funcnm: #function,line: #line, loguse: true)
                let strCanmes = "釣り銭機との通信速度が遅い為、精算を中止します。"
                _ = ConfsetRtn(confirmstatus: "", announce: strCanmes)//メッセージの表示だけ
                annaunce = strCanmes
                blnCan = true //ループを抜ける
                iRtn = 97
                break
            }
            //</Add 20220421 計数時間超過対応 ver1.30>
            if chargerrep.starts(with: "{"){
                let jsonString: String = chargerrep
                // JSON文字列をData型に変換
                var personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
                
                do {
                    // パースする
                    let items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                    let mes = items["message"] as! String
                    sendmes = mes
                    personalData =  mes.data(using: String.Encoding.utf8)!
                } catch {
                    print(error)
                    blnCan = true //ループを抜ける
                    //<Add 20220308 ログ書き出し V1.29>
                    logpara = "計数リードパースエラー1" + jsonString
                    TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
                    //</Add 20220308 ログ書き出し V1.29>
                }
                if (sendmes.starts(with: "{")) {
                    strKeisu = sendmes
                    do {
                        // パースする
                        let items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                        deposit = items["合計金額"] as? String ?? ""
                        charge = items["釣銭金額"] as? String ?? ""
                        iDeposit = Int(deposit) ?? 0
                        strStopcd = items["確認状態"] as? String ?? ""
                        //<Add 20211018 V1.10 精算可能になるまでは表示側の情報を使用>
                        //DispatchQueue.main.async {
                        confirmstatus = strStopcd
                        //}
                        //</Add 20211018 V1.10 精算可能になるまでは表示側の情報を使用>
                        //<Add 20211120 計数開始していなかった場合の対処 V1.19> このループ内では必ず計数開始していなければならない
                        let strKeisu = items["計数情報"] as? String ?? ""
                        let strTeisi = items["計数停止"] as? String ?? ""
                        if !(strKeisu == "1" && strTeisi == "0") {
                            iRtn = 96
                            return iRtn
                        }
                        //<Add 20211120 計数開始していなかった場合の対処 V1.19>
                        let iCharge: Int = Int(charge) ?? 0
                        if (strStopcd == "0" && iCharge > 0){
                            let blnable = Subformview.chargeable(chargeamount: iCharge, host: profile.changerip, port: profile.changerport)
                            if !blnable {
                                annaunce = "おつりが不足しています。"
                            }
                        }
                        //</Add 20211203 おつり不足表示 V1.20>
                        
                        //</Add 20211203 おつり不足表示 V1.20>
                    } catch {
                        print(error)
                        blnCan = true //ループを抜ける
                        //<Add 20220308 ログ書き出し V1.29>
                        logpara = "計数リードパースエラー2" + jsonString
                        TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
                        //</Add 20220308 ログ書き出し V1.29>
                    }
                }
                //<Add 20211106 メッセージ異常はブレークさせない V1.14> 精算しておつりが出ない対応になる？
                else{
                    NSLog("KeisuReadRtnによる読込エラー1")
                    //                        iCnter += 1
                    //                        if iCnter > iErlmt {
                    //                            NSLog("KeisuReadRtnによるエラー")
                    //                            blnCan = true //ループを抜ける
                    //                        }else{
                    //                            NSLog("KeisuReadRtnによる読込エラー1")
                    //                            Thread.sleep(forTimeInterval: 0.5)
                    //                            continue
                    //                        }
                }
                //</Add 20211106 メッセージ異常はブレークさせない V1.14>
            }
            //<Add 20210930 事務側キャンセル V1.9>
            if (strStopcd == "4"){
                blnCan = true //事務側キャンセルでループを抜ける
                break //スリープ回避
            }
            //</Add 20210930 事務側キャンセル V1.9>
            if (strStopcd == "3"){
                blnCan = true //キャンセルでループを抜ける
                break //スリープ回避
            }
            if ( strStopcd == "2"){
                blnBrk = true//精算でループを抜ける
                break //スリープ回避
            }
            Thread.sleep(forTimeInterval: 1)
            
            //1semaphore.signal()
            //1}
            //1semaphore.wait()
        }
        //<Add 20220308 ログ書き出し V1.29>
        logpara = "計数リードループ終了->strStopcd:" + strStopcd + " chargerrep:" + chargerrep
        TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
        //</Add 20220308 ログ書き出し V1.29>

        //計数の停止予約を釣り銭機に送信、計数終了状態になるまで投入金額の計数を繰り返す
        //上のループでキャンセルの場合でも、停止・終了は必要
        blnBrk = false
        chargerrep = KeisuStopRtn()
        var rpl = ReturnMessage(replay: chargerrep)//<Add 20211122 V1.19 />
        if(rpl.starts(with: "NAC") || rpl.count == 0){
            NSLog("KeisuStopRtnによるエラー")
            iRtn = 91
            return iRtn
        }
        
        var strDevcd: String = ""
        iCnter = 0 //<Add 20211108>
        while !blnBrk {
            chargerrep = KeisuReadRtn()
            strRead = chargerrep //<Add 20211118 V1.17 />
            if chargerrep.starts(with: "{"){
                let jsonString: String = chargerrep
                var personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
                
                do {
                    // パースする
                    var items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                    let mes = items["message"] as! String
                    personalData =  mes.data(using: String.Encoding.utf8)!
                    // パースする
                    if (mes.starts(with: "{")){
                        strKeisu = mes
                        
                        items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                        strDevcd = items["装置状態"] as? String  ?? ""
                        deposit = items["合計金額"] as? String ?? ""
                        charge = items["釣銭金額"] as? String ?? ""
                        iDeposit = Int(deposit) ?? 0
                    }
                    //<Add 20211106 メッセージ異常はブレークさせない V1.14> 精算しておつりが出ない対応になる？
                    else{
                        NSLog("KeisuReadRtnによる読込エラー2")
                        //                        iCnter += 1
                        //                        if iCnter > iErlmt {
                        //                            NSLog("KeisuReadRtnによるエラー")
                        //                            blnBrk = true
                        //                        }else{
                        //                            NSLog("KeisuReadRtnによる読込エラー2")
                        //                            Thread.sleep(forTimeInterval: 0.5)
                        //                            continue
                        //                        }
                    }
                    //</Add 20211106 メッセージ異常はブレークさせない V1.14>
                } catch {
                    print(error)
                    blnBrk = true //ループを抜ける
                }
            }else{
                //Json形式で無ければ、何らかの不具合発生
                //ループは抜けて良いか？
                //blnBrk = true
            }
            //装置状態(0:その他 1:計数動作中(SOH と同等) 2:計数停止中(EM と同等))
            if strDevcd != "1" {
                blnBrk = true
            }else{
                //sleep(1)
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        //計数の終了　装置状態＝0でも発行する
        chargerrep = KeisuEndRtn()
        rpl = ReturnMessage(replay: chargerrep)//<Add 20211122 V1.19 />
        if(rpl.starts(with: "NAC") || rpl.count == 0){
            NSLog("KeisuEndRtnによるエラー")
            iRtn = 92
            return iRtn
        }
        
        //取消ボタン・釣銭機以外のエラーの場合は、投入金額を排出して終了
        if blnCan {
            //<Add 20211111 ログ書き出し V1.16>
            let logpara = "表示側キャンセル->会員番号:" + customercode + " 氏名:" + customername + " 請求額:" + price + " 確認情報:" + strStopcd + " 釣り銭機情報:"  + strRead
            TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20211111 ログ書き出し V1.16>
            
            //<Add 20211105 事務側キャンセル V1.12>
            if (strStopcd == "4"){
                iRtn = 2 //事務側キャンセルでループを抜ける
                return iRtn
            }
            //</Add 20211105 事務側キャンセル V1.12>
            
            if iDeposit != 0 {
                let blnable = Subformview.chargeable(chargeamount: iDeposit, host: profile.changerip, port: profile.changerport)
                if blnable {
                    chargerrep = PayoutRtn(charge: deposit)
                    ResetKeisubuff()
                    //<Upd 20220428  計数時間超過対応 ver1.30>
                    //iRtn = 1
                    if iRtn != 97 {
                        iRtn = 1
                    }
                    //</Upd 20220428  計数時間超過対応 ver1.30>
                }else{
                    iRtn = 94
                }
                NSLog("seisan2 CancelPayout廃止 1")
            }else{
                //<Upd 20220428  計数時間超過対応 ver1.30>
                //iRtn = 1
                if iRtn != 97 {
                    iRtn = 1
                }
                //</Upd 20220428  計数時間超過対応 ver1.30>
            }
            return iRtn
        }
        
        //計数終了後の金額を読み取る。念のためループ処理にしている
        blnBrk = false
        iCnter = 0 //<Add 20211108>
        while !blnBrk {
            chargerrep = KeisuReadRtn()
            
            //<Add 20211111 ログ書き出し V1.16>
            let logpara = "表示側最終計数リード->会員番号:" + customercode + " 氏名:" + customername + " 請求額:" + price + " 釣り銭機情報:"  + chargerrep
            TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
            //</Add 20211111 ログ書き出し V1.16>
            
            if chargerrep.starts(with: "{"){
                let jsonString: String = chargerrep
                var personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
                
                do {
                    // メッセージをパースする
                    var items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                    let mes = items["message"] as! String
                    personalData =  mes.data(using: String.Encoding.utf8)!
                    // パースする
                    if(mes.starts(with: "{")){
                        strKeisu = mes
                        items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                        strStopcd = items["確認状態"] as? String ?? ""
                        //<Add 20210914>
                        deposit = items["合計金額"] as? String ?? ""
                        charge = items["釣銭金額"] as? String ?? ""
                        iDeposit = Int(deposit) ?? 0
                        //</Add 20210914>
                    }
                    //<Add 20211106 メッセージ異常はブレークさせない V1.14> 精算しておつりが出ない対応になる？
                    else{
                        iCnter += 1
                        if iCnter > iErlmt {
                            NSLog("KeisuReadRtnによるエラー")
                            iRtn = 95
                            return iRtn
                        }else{
                            NSLog("KeisuReadRtnによる読込エラー3")
                            Thread.sleep(forTimeInterval: 0.5)
                            continue
                        }
                    }
                    //</Add 20211106 メッセージ異常はブレークさせない V1.14>
                } catch {
                    print(error)
                    blnCan = true //ループを抜ける
                    break
                }
            }else{
                //<Upd 20211106 メッセージ異常はブレークさせない V1.14> 精算しておつりが出ない対応になる？
                //blnCan = true //返却メッセージ異常でループを抜ける
                //break
                iCnter += 1
                if iCnter > iErlmt {
                    NSLog("KeisuReadRtnによるエラー")
                    iRtn = 95
                    return iRtn
                }else{
                    NSLog("KeisuReadRtnによる読込エラー4")
                    Thread.sleep(forTimeInterval: 0.5)
                    continue
                }
                //</Upd 20211106 メッセージ異常はブレークさせない V1.14>
            }
            //確認状態：非表示中→0 表示中→1 確認押下→2 キャンセル->3 事務側キャンセル->4
            //<Add 20210930 事務側キャンセル V1.9>
            if (strStopcd == "4"){
                blnCan = true //事務側キャンセルでループを抜ける
                break //スリープ回避
            }
            //</Add 20210930 事務側キャンセル V1.9>
            if (strStopcd == "3"){
                blnCan = true //キャンセル押下でループを抜ける
                break
            }
            if strStopcd == "2" {
                //<Add 20211030 V1.12> 釣銭出力をループを抜けた後に移動
                blnBrk = true
                //</Add 20211030 V1.12>
            }else{
                //sleep(1)
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        //取消ボタン・釣銭機以外のエラーの場合は、投入金額を排出
        if blnCan {
            
            iRtn = 1
            
            //<Add 20210930 事務側キャンセル V1.9>
            if (strStopcd == "4"){
                iRtn = 2 //事務側キャンセルでループを抜ける
            }
            //</Add 20210930 事務側キャンセル V1.9>
            return iRtn //サーバー側がそのままの状態で放置する？
        }
        
        //確認押下でループ終了の時、スマレジ・アプリに戻る
        if strStopcd == "2" {
            //<Add 20211030 V1.12> 釣銭出力をループを抜けた後に移動
            //おつり有りなら釣銭出金する。ただし、釣銭不足等で出金エラーとなった場合は、確認待ちに戻る
            let icharge:Int32 = Int32(charge) ?? 0
            //<Upd 20220422 V1.30>
            //if (icharge > 0){
            if (icharge > 0 && iDeposit > 0){
            //</Upd 20220422 投入金0円排出抑止 V1.30>
                //おつり出金と成否による処理分け
                
                //<Del 20211011 V1.9 />let seisabf = SeisaRtn()
                
                chargerrep = PayoutRtn(charge: charge)
                let rep = ReturnMessage(replay: chargerrep)
                if (rep == "ACK"){
                    blnBrk = true
                }
                else if(rep == "ETB"){
                    //正常終了だが収納庫がニアエンプティまたはエンプティ
                    blnBrk = true
                }
                else if (rep == "CAN" || rep == "BEL" || rep == "NAK"){
                    //確認状態を表示中(1)に戻す
                    blnBrk = true //<Add 20211011 V1.9 />
                }
                else {
                    //確認状態を表示中(1)に戻す
                    chargerrep = ConfsetRtn(confirmstatus: "1", announce: "")
                    //メッセージの表示
                }
                //<Add 20220423 ログ書き出し V1.30>
                let logpara = "seisan2お釣り出金" + charge
                TSILog.write(logpara, funcnm: #function, line: #line, loguse: profile.loguse)
                //</Add 20220423 ログ書き出し V1.30>
            }
            else{
                //おつり0円時
                //<Add 20211112 精算終了メッセージ保持の為 ver1.16>
                Thread.sleep(forTimeInterval: 2)
                //</Add 20211112 精算終了メッセージ保持の為 ver1.16>
                blnBrk = true
            }
            ResetKeisubuff()
            //</Add 20211030 V1.12> 釣銭出力をループを抜けた後に移動
            
            iRtn = 0
        }
        //抜き取り待ちの制御？CallSmaregiの後でも動く？
        //抜き取り待ちです。
        
        return iRtn
    }//seisan2()
    //</Add 20210914 ver1.5>
    
    //スマレジアプリから取引履歴の取消処理が呼ばれた時の処理
    func henkin() {
        //返金額の取得
        let strhenkin = self.price
        //出金可能か判定
        let inthenkin = Int(strhenkin) ?? 0
        let blnable = Subformview.chargeable(chargeamount: inthenkin, host: profile.changerip, port: profile.changerport)
        if blnable {
            //出金
            reply = Subformview.payout6_telegram_get(host: profile.changerip, port: profile.changerport, amount: strhenkin)
        }
        //スマレジ・アプリへ結果返却
        if blnable {
            //出金完了
            reply = CallSmaregi(smcallback: callback, rslt: "1", miss: "", slip: slipnumber, prc: price)
        }else{
            //キャンセル
            reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "金額不足の為キャンセルしました。", slip: slipnumber, prc: price)
        }
    }
    
    //<Add 20210930 V1.9>
    //計数リード状態の釣り銭機を停止させ、
    //paytype=2で釣り銭をpaytype=3で投入金額を返金する
    func emergencyend(paytype: Int) -> Int {
        var iRtn: Int = 90 //90以上はエラー状態での終了
        var iDeposit:Int = 0
        let iBilling: Int = Int(billingamount) ?? 0
        var iCharge: Int = 0
        var blnBrk: Bool = false
        var strKeisu: String = ""//キャンセル時の返金用
        
        if (profile.changerip == "" || profile.changerport == ""){
            return iRtn
        }
        //計数の停止予約を釣り銭機に送信、計数終了状態になるまで投入金額の計数を繰り返す
        //上のループでキャンセルの場合でも、停止・終了は必要
        blnBrk = false
        chargerrep = Subformview.keisustop_telegram_get(host: profile.changerip, port: profile.changerport)
        //<Add 20211120 コマンドのすっぽ抜け回避？ V1.19>
        var iRp:Int = 0
        while (chargerrep != "ACK"){
            Thread.sleep(forTimeInterval: 0.05)
            chargerrep = Subformview.keisustop_telegram_get(host: profile.changerip, port: profile.changerport)
            iRp += 1
            if iRp > 5 {
                break
            }
        }
        //</Add 20211120 コマンドのすっぽ抜け回避？ V1.19>
        if(chargerrep.starts(with: "NAC") || chargerrep.count == 0){
            NSLog("keisustop_telegram_getによるエラー")
            iRtn = 91
            return iRtn
        }
        Thread.sleep(forTimeInterval: 0.2)//各teregramの間にスリープを設ける
        
        var strDevcd: String = ""
        var iReaderr: Int = 0
        while !blnBrk {
            //NSLog("emergencyend keisuread前")
            chargerrep = Subformview.keisuread_telegram_get(host: profile.changerip, port: profile.changerport)
            strKeisu = chargerrep
            if strKeisu.starts(with: "{"){
                let jsonString: String = strKeisu
                let personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
                
                do {
                    // パースする
                    let items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
                    strDevcd = items["装置状態"] as? String ?? ""
                    deposit = items["合計金額"] as? String ?? ""
                    iDeposit = Int(deposit) ?? 0
                    iCharge = iDeposit - iBilling
                    if iCharge < 0 {
                        iCharge = 0
                    }
                    charge = String(iCharge)
                } catch {
                    NSLog("emergencyend \(error)")
                    //blnKeisureaderr = true
                    //20211104 ここで入れているAlertは素通りする
                    showingAlert = AlertItem(alert: Alert(title: Text("計数リードエラー"), message: Text("投入額を取得出来ませんでした。"), dismissButton: .cancel(Text("OK"), action: {
                        reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "投入額の取得エラーによりキャンセルされました。", slip: slipnumber, prc: price)
                        Thread.sleep(forTimeInterval: closingsleep)
                        exit(0)
                    })))
                    //print(error)
                    // blnBrk = true //ループを抜ける
                    //break
                }
            }else{
                //Json形式で無ければ、何らかの不具合発生
                //<Add 20211018 V1.10>
                //blnKeisureaderr = true
                //20211104 ここで入れているAlertは素通りする
                showingAlert = AlertItem(alert: Alert(title: Text("計数リードエラー"), message: Text("投入額を取得出来ませんでした。"), dismissButton: .cancel(Text("OK"), action: {
                    reply = CallSmaregi(smcallback: callback, rslt: "0", miss: "投入額の取得エラーによりキャンセルされました。", slip: slipnumber, prc: price)
                    Thread.sleep(forTimeInterval: closingsleep)
                    exit(0)
                })))
                iReaderr += 1
                if iReaderr >= 5 { //読込エラーが５回発生したらループを抜ける
                    blnBrk = true
                }
                //</Add 20211018 V1.10>
            }
            //装置状態(0:その他 1:計数動作中(SOH と同等) 2:計数停止中(EM と同等))
            if strDevcd != "1" {
                blnBrk = true
            }else{
                Thread.sleep(forTimeInterval: 0.5)
            }
        }
        //計数の終了　装置状態＝0でも発行する
        //NSLog("emergencyend keisuend前")
        Thread.sleep(forTimeInterval: 0.2)//各teregramの間にスリープを設ける
        chargerrep = Subformview.keisuend_telegram_get(host: profile.changerip, port: profile.changerport)
        //<Add 20211120 コマンドのすっぽ抜け回避？ V1.19>
        iRp = 0
        while (chargerrep != "ACK"){
            Thread.sleep(forTimeInterval: 0.05)
            chargerrep = Subformview.keisuend_telegram_get(host: profile.changerip, port: profile.changerport)
            iRp += 1
            if iRp > 5 {
                break
            }
        }
        //</Add 20211120 コマンドのすっぽ抜け回避？ V1.19>
        if(chargerrep.starts(with: "NAC") || chargerrep.count == 0){
            NSLog("keisuend_telegram_getによるエラー")
            iRtn = 92
            return iRtn
        }
        
        if iReaderr >= 5 { //計数読込エラー時は金銭放出しない
            iRtn = 93
            return iRtn
        }
        if paytype == 2 {
            //釣り銭金額を排出して終了
            if iCharge > 0 {
                let chg: String = String(iCharge)
                
                //釣り銭の金種が足りるかの判定が必要
                chargerrep = Subformview.payout6_telegram_get(host: profile.changerip, port: profile.changerport, amount: chg)
                
                iRtn = 1
            }else{
                iRtn = 0
            }
            //<Add 20211101 ver1.12> 計数のリセットを追加
            ResetKeisubuff()
            NSLog("emergencyend 計数のリセットを追加")
            //</Add 20211101 ver1.12> 計数のリセットを追加
        }
        else if paytype == 3 {
            //投入金額を排出して終了
            if iDeposit != 0 {
                //<Upd 20211101 ver1.12> 金額指定放出に変更
                //chargerrep = Subformview.payout_telegram_get(host: profile.changerip, port: profile.changerport, pieces: strKeisu)
                //iRtn = 1
                
                let blnable = Subformview.chargeable(chargeamount: iDeposit, host: profile.changerip, port: profile.changerport)
                if blnable { //金種が足りない時は放出及びクリアしない
                    chargerrep = Subformview.payout6_telegram_get(host: profile.changerip, port: profile.changerport, amount: deposit)
                    ResetKeisubuff()
                    iRtn = 1
                }else {
                    iRtn = 94 //釣り銭放出不可
                }
                NSLog("emergencyend 金額指定放出に変更")
                //</Upd 20211101 ver1.12>
            }else{
                iRtn = 0
            }
        }
        
        return iRtn
    }//emergencyend()
    //</Add 20210930 V1.9>
    
    //<Add 20211014 V1.9>
    func getComma(num: String) -> String {
        let intnum = Int(num) ?? 0
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let number = "\(formatter.string(from: NSNumber(value: intnum)) ?? "")円"
        
        return number
    }//getComma()
    //</Add 20211014 V1.9>
    
    //<Add 20211101 ver1.12> おつりの放出を待って計数金額をクリアする
    func ResetKeisubuff() {
        var blnLp = true
        Thread.sleep(forTimeInterval: 0.2)//各teregramの間にスリープを設ける
        while blnLp {
            let strSt = Subformview.enq_telegram_get(host: profile.changerip, port: profile.changerport)
            NSLog("enqstate:\(strSt)")
            //"DC2"(抜取り待ち),"DC4"(放出可動作中),"SUB"(動作中)
            if (strSt == "DC2" || strSt == "DC4" || strSt == "SUB") { //"EM"(計数停止中)"SOH"(計数中)も加える？
                Thread.sleep(forTimeInterval: 0.5)// 釣り銭放出した時のための待ち
            }else{
                blnLp = false
            }
        }
        
    } //ResetKeisubuff()
    //</Add 20211101 ver1.12>
    //
}

struct Subformview: View {
    @State var operation: String = ""
    @State var callback: String = ""
    @State var slipnumber: String = ""
    @State var price: String = ""
    @State var transaction: String = ""
    @State var chanerappip: String = ""
    @State var reply: String = "" //スマレジアプリに返却する値
    @State var chargerrep: String = "" //実行結果 //釣り銭機からの返信
    @State var deposit: String = "" //投入金額
    @State var charge: String = "" //おつり
    
    @State var annaunce: String = "" //案内
    
    @ObservedObject var profile = UserProfile()
    
    var body: some View {
        Form {
            Button(action: { exit(0) }, label: {
                Text("このアプリを閉じる(ホームボタンは使用しないで下さい。)")
            })
            Section(header: Text("表示用端末のアドレスとポート")){
                TextField("表示用端末のipアドレス:ポート番号", text: $profile.changerappip)
                //高さが嵩むのでコメント化 .padding()
                //<Add 20211013 V1.9>
                TextField("プログラム終了待機時間(未設定時1.0秒)", text: $profile.closingsleep)
                //</Add 20211013 V1.9>
                //<Add 20211111 V1.16>
                Toggle(isOn: $profile.loguse){
                    Text("ログを記録する：" + (profile.loguse ? "On": "Off"))
                }
                //</Add 20211111 V1.16>
                //<Add 20220507 V1.30>
                TextField("指定時間以上経っても投入金額を読み込めない時、エラーを発生させます。(未設定時7秒)", text: $profile.keisureadtimelimit) //投入金額計数制限時間
                //</Add 20220507 V1.30>
                Text("Version 1.34")
                //.padding()
            }
            Section(header: Text("釣銭機操作（直接）")){
                TextField("釣銭機のアドレス", text: $profile.changerip)
                //.padding()
                TextField("釣銭機のポート番号", text: $profile.changerport)
                //.padding()
                Button(action: {chargerrep = Subformview.enq_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                    Text("導通確認")
                })
                //                Button(action: {chargerrep = eot_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                //                    Text("通信初期化")
                //                })
                Button(action: {chargerrep = Subformview.seisa_telegram_get(host: profile.changerip, port: profile.changerport,deley: -4)
                    chargerrep = Subformview.SeisaResponse(strHx: chargerrep)
                }, label: {
                    Text("精査取得")
                })
                Button(action: {
                    chargerrep = Subformview.keisustart_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                        Text("計数開始(一つ前のコマンドが計数終了の時は、投入金額がリセットされる。)")
                    })
                Button(action: {
                    chargerrep = Subformview.keisuread_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                        Text("計数リード")
                    })
                Button(action: { chargerrep = Subformview.keisustop_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                    Text("●計数停止（予約）")
                })
                Button(action: { chargerrep = Subformview.keisuend_telegram_get(host: profile.changerip, port: profile.changerport) }, label: {
                    Text("●計数終了")
                })
                Button(action: {chargerrep = Subformview.payout6_telegram_get(host: profile.changerip, port: profile.changerport, amount: charge) }, label: {
                    Text("●釣銭放出(釣銭金額に入力した金額を放出します)")
                })
                TextField("釣銭金額(1円以上の金額を半角数字で入力して下さい)", text: $charge)
                //.padding()
            }
            
            Section(header: Text("表示端末に対する処理")){
                Button(action: { reply = ResetdispRtn() }, label: {
                    Text("●初期表示に戻す")
                })
                Button(action: { chargerrep = SeisaRtn() }, label: {
                    Text("精査情報取得")
                })
                Button(action: {chargerrep = ConfsetRtn(confirmstatus: "1", announce: "日本語アナウンス")}, label: {
                    Text("確認状態セット")
                })
                Button(action: { /* seisan() */ }, label: {
                    Text("エミュレート")
                })
                //hyojiからのレスポンス
                Text("\(chargerrep)")
                
                Button(action: { reply = CallSmaregi(smcallback: callback, rslt: "1", miss: "", slip: slipnumber, prc: price) }, label: {
                    Text("スマレジへ結果を返却")
                })
                Button(action: { writingToFile(text: "logtest") }, label: {
                    Text("翌日ログ書き出し")
                })
            }
            
            Section(header: Text("釣銭機操作（表示端末経由）")){
                Button(action: {chargerrep = ENQSendRtn() }, label: {
                    Text("導通確認")
                })
                Button(action: {EOTSend() }, label: {
                    Text("送信終了・初期化")
                })
                Button(action: {
                    //取引内容(Json)から氏名と会員コードを取得
                    let tranString: String = transaction
                    let tranData: Data =  tranString.data(using: String.Encoding.utf8)!
                    var strPtnum: String = ""
                    var strPtname: String = ""
                    do {
                        // パースする
                        let hditems = try JSONSerialization.jsonObject(with: tranData) as! Dictionary<String, Any>
                        let heads = hditems["transactionHead"] as! Dictionary<String, Any>
                        strPtnum = heads["customerCode"] as? String ?? ""
                        strPtname = heads["customerName"] as? String ?? ""
                    } catch {
                        print(error)
                    }
                    
                    chargerrep = KeisuStartonRtn(price: price, customercode: strPtnum, customername: strPtname) }, label: {
                        Text("計数開始")
                    })
                Button(action: Call_KeisuReadRtn, label: {
                    Text("計数リード")
                })
                Button(action: { chargerrep = KeisuStopRtn() }, label: {
                    Text("●計数停止（予約）")
                })
                Button(action: { chargerrep = KeisuEndRtn() }, label: {
                    Text("●計数終了")
                })
                Button(action: { KeisuRestart() }, label: {
                    Text("計数再開")
                })
                Button(action: { Reset() }, label: {
                    Text("リセット")
                })
                Button(action: {chargerrep =  PayoutRtn(charge: charge) }, label: {
                    Text("●釣銭放出")
                })
                TextField("釣銭金額", text: $charge)
                //.padding()
            }
            Group{
                Section(header: Text("処理の種類")){
                    Text("\(operation)")
                }
                Section(header: Text("終了後の呼出URL")){
                    Text("\(callback)")
                }
                Section(header: Text("決済識別子")){
                    Text("\(slipnumber)")
                }
                Section(header: Text("精算中の金額")){
                    Text("¥\(price)")
                }
                Section(header: Text("取引内容")){
                    Text("\(transaction)")
                }
                Section(header: Text("返却内容")){
                    Text("\(reply)")
                }
            }
        }
        /* ↓イベントのタイミングが複数あるので、使えない
         .onAppear(perform: {
         if (operation != ""){
         seisan()
         }
         })
         */
    }
    //<Add 20211112 V1.16>
    // ファイル書き込みサンプル
    func writingToFile(text: String) {
        
        /// ①DocumentsフォルダURL取得
        guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("フォルダURL取得エラー")
        }
        
        /// ②対象のファイルURL取得
        let dt = Date()
        let calendar = Calendar(identifier: .gregorian)
        //前月の同日の翌日ログファイル
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: dt)!
        let tomorrow = calendar.component(.day, from: modifiedDate)
        let delfile = "log" + tomorrow.description + ".csv"
        let fileURL = dirURL.appendingPathComponent(delfile)
        
        /// ③ファイルの書き込み
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Error: \(error)")
        }
    }
    //</Add 20211112 V1.16>
    
    //Contentview内の関数
    func Call_KeisuReadRtn(){
        chargerrep = KeisuReadRtn()
    }
    
    //<Add 20210930 V1.9>
    //計数リード送信
    static func keisuread_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x41 //計数リード
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x30
        let etx: UInt8 = 0x03
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            Thread.sleep(forTimeInterval: 0.5)
            //<Upd 20211115 V1.16>
            //strRtn = recv_enq(connection: connection)
            var iEnd: Int = 0
            strRtn = recv_keisuread(connection: connection)
            while strRtn.count < 123 {
                Thread.sleep(forTimeInterval: 0.1)
                strRtn += recv_keisuread(connection: connection)
                
                iEnd += 1
                if iEnd > 5 {
                    break
                }
            }
            strRtn = KEISUResponse(strHx: strRtn)
            //</Upd 20211115 V1.16>
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //</Add 20210930 V1.9>
    //<Add 20210826 釣銭機直接操作>
    
    //計数スタート送信
    static func keisustart_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x45 //計数開始
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x30
        let etx: UInt8 = 0x03
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            Thread.sleep(forTimeInterval: 0.1)//<Add 0211120 コマンドのすっぽ抜け回避？ V1.18 />
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    
    //計数停止送信
    //計数処理の停止を予約します
    //予約後、以下の条件を全て満たすと、計数停止中となります。
    //・投入口／挿入口の媒体を全て計数した。
    //・紙幣化セットがフルではない
    //・リジェクト媒体の抜き取り待ち中ではない
    //・計数動作中（SOH時）のみコマンドが有効です
    //・計数停止中になると、媒体を投入口／納入口に入れても計数動作を開始しません。（計数動作禁止）
    static func keisustop_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x47 //計数停止
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x30
        let etx: UInt8 = 0x03
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            Thread.sleep(forTimeInterval: 0.1)//<Add 0211120 コマンドのすっぽ抜け回避？ V1.18 />
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //計数終了送信(計数停止中のみコマンドを受け付ける)
    static func keisuend_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x46 //計数終了
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x30
        let etx: UInt8 = 0x03
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)//釣銭機へコマンドの送信
            Thread.sleep(forTimeInterval: 0.1)//<Add 0211120 コマンドのすっぽ抜け回避？ V1.18 />
            strRtn = recv_enq(connection: connection) //中で釣り銭機から受信した結果の編集
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //釣銭放出指示送信
    static func payout6_telegram_get(host:String, port:String, amount:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x31 //金額指定放出
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x36 //データ部６桁
        var D0: UInt8 = 0x00
        var D1: UInt8 = 0x00
        var D2: UInt8 = 0x00
        var D3: UInt8 = 0x00
        var D4: UInt8 = 0x00
        var D5: UInt8 = 0x00
        let etx: UInt8 = 0x03
        
        let substr : (String, Int, Int) -> String = { text, from, length in
            let to = text.index(text.startIndex, offsetBy:from + length)
            let from = text.index(text.startIndex, offsetBy:from)
            return String(text[from...to])
        }
        let amnt: Int = Int(amount) ?? 0
        let amount6: String = String(format: "%06d", amnt)
        let cd0 = substr(amount6, 0, 0)
        var ach:[UInt8] = Array(cd0.utf8)
        D0 = ach[0]
        let cd1 = substr(amount6, 1, 0)
        ach = Array(cd1.utf8)
        D1 = ach[0]
        let cd2 = substr(amount6, 2, 0)
        ach = Array(cd2.utf8)
        D2 = ach[0]
        let cd3 = substr(amount6, 3, 0)
        ach = Array(cd3.utf8)
        D3 = ach[0]
        let cd4 = substr(amount6, 4, 0)
        ach = Array(cd4.utf8)
        D4 = ach[0]
        let cd5 = substr(amount6, 5, 0)
        ach = Array(cd5.utf8)
        D5 = ach[0]
        
        
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, D0, D1, D2, D3, D4, D5, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //<Add 20210914 ver1.5>
    //釣銭放出枚数指定(3桁)送信
    static func payout_telegram_get(host:String, port:String, pieces:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x35 //枚数指定放出
        let L0: UInt8 = 0x31
        let L1: UInt8 = 0x3E //データ部30桁
        var DR: [UInt8] = [0x00]
        let etx: UInt8 = 0x03
        
        //文字照部分抜き出し関数
        let substr : (String, Int, Int) -> String = { text, from, length in
            let to = text.index(text.startIndex, offsetBy:from + length)
            let from = text.index(text.startIndex, offsetBy:from)
            return String(text[from...to])
        }
        
        let kinsh = ["2000円", "10000円", "5000円", "1000円", "500円", "100円", "50円", "10円", "5円", "1円"]
        //piecesをJsonに変換して金種ごとの枚数を取得する
        let personalData: Data =  pieces.data(using: String.Encoding.utf8)!
        print(pieces)
        
        do {
            // パースする
            var items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
            DR.removeAll()
            for i in 0..<kinsh.count {
                let maisu = items[kinsh[i]] as? String ?? "000"
                let cd0 = substr(maisu, 0, 0)
                var ach:[UInt8] = Array(cd0.utf8)
                DR.append(ach[0])
                let cd1 = substr(maisu, 1, 0)
                ach = Array(cd1.utf8)
                DR.append(ach[0])
                let cd2 = substr(maisu, 2, 0)
                ach = Array(cd2.utf8)
                DR.append(ach[0])
            }
        } catch {
            print(error)
        }
        
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1]
        for x in 0...DR.count-1{
            CMD.append(DR[x])
        }
        CMD.append(etx)
        
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //釣銭放出枚数指定(２桁)送信
    static func payout_telegram_get2(host:String, port:String, pieces:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x35 //枚数指定放出
        let L0: UInt8 = 0x31
        let L1: UInt8 = 0x34 //データ部30桁
        var DR: [UInt8] = [0x00]
        let etx: UInt8 = 0x03
        
        //文字照部分抜き出し関数
        let substr : (String, Int, Int) -> String = { text, from, length in
            let to = text.index(text.startIndex, offsetBy:from + length)
            let from = text.index(text.startIndex, offsetBy:from)
            return String(text[from...to])
        }
        
        let kinsh = ["2000円", "10000円", "5000円", "1000円", "500円", "100円", "50円", "10円", "5円", "1円"]
        //piecesをJsonに変換して金種ごとの枚数を取得する
        let personalData: Data =  pieces.data(using: String.Encoding.utf8)!
        
        do {
            // パースする
            var items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
            DR.removeAll()
            for i in 0..<kinsh.count {
                let maisu = items[kinsh[i]] as? String ?? "000"
                let cd0 = substr(maisu, 1, 0)
                var ach:[UInt8] = Array(cd0.utf8)
                DR.append(ach[0])
                let cd1 = substr(maisu, 2, 0)
                ach = Array(cd1.utf8)
                DR.append(ach[0])
                //                let cd2 = substr(maisu, 2, 0)
                //                ach = Array(cd2.utf8)
                //                DR.append(ach[0])
            }
        } catch {
            print(error)
        }
        
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1]
        for x in 0...DR.count-1{
            CMD.append(DR[x])
        }
        CMD.append(etx)
        
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //</Add 20210914 ver1.5>
    
    //ENQ(状態通知)
    static func enq_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            //if connection.state == .ready {
            
            //}
            let enqbytes: [UInt8] = [0x05]
            send(connection: connection, sendbytes: enqbytes)
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //EOT送信
    func eot_telegram_get(host:String, port:String) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            let enqbytes: [UInt8] = [0x04]
            send(connection: connection, sendbytes: enqbytes)
            strRtn = recv_enq(connection: connection)
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //精査送信
    static func seisa_telegram_get(host:String, port:String,deley:Int) -> String
    {
        var strRtn: String = ""
        
        let connection : NWConnection
        
        let stx: UInt8 = 0x02
        let dc1: UInt8 = 0x11
        let dh1: UInt8 = 0x32 //精査
        let L0: UInt8 = 0x30
        let L1: UInt8 = 0x30
        let etx: UInt8 = 0x03
        var CMD:[UInt8] = [stx, dc1, dh1, L0, L1, etx]
        var bcc:[UInt8] = [0x00]
        for i in 1..<CMD.count{ //パリティ計算(２バイト目から)
            bcc[0] ^= CMD[i]
        }
        CMD.append(bcc[0])
        
        //doで囲んでいるのは無駄かも
        do {
            connection = tcpconnect(host: host, port: port)
            send(connection: connection, sendbytes: CMD)
            let ddeley = Double(deley) * 0.1
            Thread.sleep(forTimeInterval: 0.5 + ddeley)
            strRtn = recv_seisa(connection: connection)
            //<Add 20211115 V1.16>
            var iEnd: Int = 0
            while strRtn.count < 150 { //366 より 150 の方がいい？
                Thread.sleep(forTimeInterval: 0.1)
                strRtn += recv_seisa(connection: connection)
                
                iEnd += 1
                if iEnd > 5 {
                    break
                }
            }
            //</Add 20211115 V1.16>
            disconnect(connection: connection)
        } catch  {
            print("Error: \(error)")
        }
        
        return strRtn
    }
    //seisa受信
    //https://www.radical-dreamer.com/programming/raspberry-pi-bme280-client/#toc10
    static func recv_seisa(connection: NWConnection) -> String {
        var strRtn: String = ""
        
        let semaphore = DispatchSemaphore(value: 0)
        connection.receive(minimumIncompleteLength: 0, maximumLength: 4096, completion:{(data, context, flag, error) in
            if let error = error {
                NSLog("\(#function), \(error)")
            } else {
                if let data = data {
                    let bytes:[UInt8] = [UInt8](data)
                    var retname: String = ""
                    if(bytes.count > 0){
                        switch bytes[0] {
                        case 0x06: //正常終了
                            retname = "ACK"
                        case 0x18: //異常終了
                            retname = "CAN"
                        case 0x17: //ニアエンプティ
                            retname = "CAN"
                        case 0x15: //通信異常
                            retname = "NAK"
                        case 0x13: //セットはずれ
                            retname = "DC3"
                        case 0x1A: //動作中
                            retname = "SUB"
                        case 0x14: //放出可動作中
                            retname = "DC4"
                        case 0x01: //計数中
                            retname = "SOH"
                        case 0x19: //計数停止中
                            retname = "EM"
                        case 0x07: //動作不可
                            retname = "BEL"
                        case 0x12: //抜き取り待ち
                            retname = "DC2"
                        case 0x10: //レスポンスの先頭
                            retname = "DLE"
                        default:
                            retname = ""
                        }
                        //2バイト以上のリターンからの編集
                        if(bytes.count > 1){
                            retname = bytetohexstr(inbyte: bytes)
                            print("16進電文:" + retname)
                        }
                    }
                    print("seisaFlag:" + flag.description)
                    strRtn = retname
                    
                    /*DispatchQueue.main.async {
                     self.cntv.dispitems.chargerstatus = retname
                     }
                     */
                    //下に移動?
                    semaphore.signal()
                }
                else {
                    NSLog("receiveMessage data nil")
                }
            }
            //semaphore.signal()
        })
        
        semaphore.wait()
        
        return strRtn
    }
    //    //バイト配列を文字列にする(数字の範囲のみ処理対象)
    //    static func bytetohexstr(inbyte:[UInt8])->String{
    //        var strHex: String = ""
    //        for i in 0..<inbyte.count{
    //            if(inbyte[i] != 0x00){
    //                /*
    //                if (inbyte[i] >= 48 && inbyte[i] < 58){
    //                    strHex += String(inbyte[i]-48) + "h"
    //                }else{
    //                    strHex += String(inbyte[i]) + "h"
    //                }
    // */
    //                strHex += String(format: "%02x", inbyte[i]) + "h"
    //            }
    //        }
    //        return strHex
    //    }
    //精査時のレスポンスをjson変換する
    static func SeisaResponse(strHx: String)->String
    {
        let aHex: [Substring] = strHx.split(separator: "h");
        var dic = Dictionary<String, String>()
        var amount:Int = 0
        var jstr: String = ""
        
        if (aHex.count < 45) {
            return ""
        }
        
        var strMai: String = ""
        let iTop: Int = 4
        strMai = String(aHex[iTop+0].suffix(1))
        strMai += String(aHex[iTop+1].suffix(1))
        strMai += String(aHex[iTop+2].suffix(1))
        dic["2000円"] = strMai
        amount += 2000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+3].suffix(1))
        strMai += String(aHex[iTop+4].suffix(1))
        strMai += String(aHex[iTop+5].suffix(1))
        dic["10000円"] = strMai
        amount += 10000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+6].suffix(1))
        strMai += String(aHex[iTop+7].suffix(1))
        strMai += String(aHex[iTop+8].suffix(1))
        dic["5000円"] = strMai
        amount += 5000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+9].suffix(1))
        strMai += String(aHex[iTop+10].suffix(1))
        strMai += String(aHex[iTop+11].suffix(1))
        dic["1000円"] = strMai
        amount += 1000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+12].suffix(1))
        strMai += String(aHex[iTop+13].suffix(1))
        strMai += String(aHex[iTop+14].suffix(1))
        dic["C2000円"] = strMai
        amount += 2000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+15].suffix(1))
        strMai += String(aHex[iTop+16].suffix(1))
        strMai += String(aHex[iTop+17].suffix(1))
        dic["C10000円"] = strMai
        amount += 10000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+18].suffix(1))
        strMai += String(aHex[iTop+19].suffix(1))
        strMai += String(aHex[iTop+20].suffix(1))
        dic["C5000円"] = strMai
        amount += 5000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+21].suffix(1))
        strMai += String(aHex[iTop+22].suffix(1))
        strMai += String(aHex[iTop+23].suffix(1))
        dic["C 1000円"] = strMai
        amount += 1000 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+24].suffix(1))
        strMai += String(aHex[iTop+25].suffix(1))
        strMai += String(aHex[iTop+26].suffix(1))
        dic["500円"] = strMai
        amount += 500 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+27].suffix(1))
        strMai += String(aHex[iTop+28].suffix(1))
        strMai += String(aHex[iTop+29].suffix(1))
        dic["100円"] = strMai
        amount += 100 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+30].suffix(1))
        strMai += String(aHex[iTop+31].suffix(1))
        strMai += String(aHex[iTop+32].suffix(1))
        dic["50円"] = strMai
        amount += 50 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+33].suffix(1))
        strMai += String(aHex[iTop+34].suffix(1))
        strMai += String(aHex[iTop+35].suffix(1))
        dic["10円"] = strMai
        amount += 10 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+36].suffix(1))
        strMai += String(aHex[iTop+37].suffix(1))
        strMai += String(aHex[iTop+38].suffix(1))
        dic["5円"] = strMai
        amount += 5 * (Int(strMai) ?? 0)
        
        strMai = String(aHex[iTop+39].suffix(1))
        strMai += String(aHex[iTop+40].suffix(1))
        strMai += String(aHex[iTop+41].suffix(1))
        dic["1円"] = strMai
        amount += Int(strMai) ?? 0
        
        dic["合計金額"] = String(amount)
        
        do {
            // DictionaryをJSONデータに変換
            let jsonData = try JSONSerialization.data(withJSONObject: dic)
            // JSONデータを文字列に変換
            jstr = String(bytes: jsonData, encoding: .utf8)!
            print(jstr)
        } catch (let e) {
            print(e)
        }
        return jstr
    }
    //指定金額の排出可能判定
    static func chargeable(chargeamount: Int, host:String, port:String)->Bool {
        var blnCan = true
        var charge: Int = chargeamount
        var transtring = seisa_telegram_get(host: host, port: port, deley: 0)
        print("seisa:" + transtring)
        transtring = SeisaResponse(strHx: transtring)
        
        //<Add 20211112 ver1.16>
        //<SeisaResponseが空で返ってきたら、seisa_telegram_getを繰り返す処理を追加>
        var iEnd :Int = 0
        while (transtring == ""){
            Thread.sleep(forTimeInterval: 0.1)
            transtring = seisa_telegram_get(host: host, port: port, deley: iEnd)
            transtring = SeisaResponse(strHx: transtring)
            iEnd += 1
            if (iEnd > 5){
                break
            }
        }
        if transtring == "" {
            return false
        }
        //</Add 20211112 ver1.16>
        
        let tranData:Data = transtring.data(using: String.Encoding.utf8)!
        do {
            let dic = try JSONSerialization.jsonObject(with: tranData) as! Dictionary<String, String>
            let kinshuh: [Int] = [10000, 5000, 1000]
            let kinshuk: [Int] = [500, 100, 50, 10, 5, 1]
            var intMaisu: Int
            var intSeimai: Int
            //各金種での判定
            //紙幣と硬貨間で代替えは行われない
            //紙幣での判定
            for idx in 0...kinshuh.count-1{
                intMaisu = charge / kinshuh[idx]
                let kinen = String(kinshuh[idx]) + "円"
                intSeimai = Int(dic[kinen] ?? "0") ?? 0
                
                if (intMaisu > 0){
                    if (intMaisu <= intSeimai){
                        charge = charge - (intMaisu * kinshuh[idx])
                    } else {
                        if (idx+1 == kinshuh.count) {
                            //紙幣から硬貨の代替えはしないので、エラー
                            return false
                        }
                        
                        var chgkari = charge - (intSeimai * kinshuh[idx])
                        var iMai = chgkari / kinshuh[idx+1]
                        let kinkari = String(kinshuh[idx+1]) + "円"
                        let iSeimai = Int(dic[kinkari] ?? "0") ?? 0
                        if (iMai > iSeimai){
                            //２つ目の金種でも足りなければエラー
                            return false
                        }
                        
                        charge = charge - (intSeimai * kinshuh[idx])
                    }
                }
            }
            //硬貨での判定
            for idx in 0...kinshuk.count-1{
                intMaisu = charge / kinshuk[idx]
                let kinen = String(kinshuk[idx]) + "円"
                intSeimai = Int(dic[kinen] ?? "0") ?? 0
                
                if (intMaisu > 0){
                    if (intMaisu <= intSeimai){
                        charge = charge - (intMaisu * kinshuk[idx])
                    } else {
                        if (idx+1 == kinshuk.count) {
                            //1円以下の硬貨はないので、エラー
                            return false
                        }
                        
                        var chgkari = charge - (intSeimai * kinshuk[idx])
                        var iMai = chgkari / kinshuk[idx+1]
                        let kinkari = String(kinshuk[idx+1]) + "円"
                        let iSeimai = Int(dic[kinkari] ?? "0") ?? 0
                        if (iMai > iSeimai){
                            //２つ目の金種でも足りなければエラー
                            return false
                        }
                        
                        charge = charge - (intSeimai * kinshuk[idx])
                    }
                }
            }
            
        } catch {
            print(error)
        }
        
        if (charge > 0){
            blnCan = false
        }
        return blnCan
    }
    //</Add 20210826 釣銭機直接操作>
    
}
//<Add 20210826 釣銭機直接操作>
//接続
func tcpconnect(host: String, port: String) -> NWConnection
{
    let t_host = NWEndpoint.Host(host)
    let t_port = NWEndpoint.Port(port)
    let connection : NWConnection
    let semaphore = DispatchSemaphore(value: 0)
    
    connection = NWConnection(host: t_host, port: t_port!, using: .tcp)
    
    connection.stateUpdateHandler = { (newState) in
        switch newState {
        case .ready:
            //NSLog("Ready to send")
            //下に移動？
            semaphore.signal()//20210826
            //break
        case .waiting(let error):
            NSLog("waiting \(#function), \(error)")
        case .failed(let error):
            NSLog("failed \(#function), \(error)")
        case .setup: break
        case .cancelled: break
        case .preparing: break
        @unknown default:
            fatalError("Illegal state")//プログラムを強制終了させる関数
        }
        //↑State毎にsemaphore解除を行うべき
        //semaphore.signal()//20210826
    }
    
    let queue = DispatchQueue(label: "temphum")
    connection.start(queue:queue)
    
    semaphore.wait()
    
    return connection
}
//送信
func send(connection: NWConnection, sendbytes:[UInt8]) {
    let data = sendbytes
    let semaphore = DispatchSemaphore(value: 0)
    
    connection.send(content: data, completion: .contentProcessed { error in
        if let error = error {
            NSLog("sendエラー発生 \(#function), \(error)")
        } else {
            //下に移動?
            semaphore.signal()
        }
        //semaphore.signal()
    })
    
    semaphore.wait()
}
//受信
func recv_enq(connection: NWConnection) -> String {
    var strRtn: String = ""
    
    let semaphore = DispatchSemaphore(value: 0)
    connection.receive(minimumIncompleteLength: 0, maximumLength: 4096, completion:{(data, context, flag, error) in
        if let error = error {
            NSLog("\(#function), \(error)")
        } else {
            if let data = data {
                let bytes:[UInt8] = [UInt8](data)
                var retname: String = ""
                if(bytes.count > 0){
                    switch bytes[0] {
                    case 0x06: //正常終了
                        retname = "ACK"
                    case 0x18: //異常終了
                        retname = "CAN"
                    case 0x17: //ニアエンプティ
                        retname = "CAN"
                    case 0x15: //通信異常
                        retname = "NAK"
                    case 0x13: //セットはずれ
                        retname = "DC3"
                    case 0x1A: //動作中
                        retname = "SUB"
                    case 0x14: //放出可動作中
                        retname = "DC4"
                    case 0x01: //計数中
                        retname = "SOH"
                    case 0x19: //計数停止中
                        retname = "EM"
                    case 0x07: //動作不可
                        retname = "BEL"
                    case 0x12: //抜き取り待ち
                        retname = "DC2"
                    case 0x10: //レスポンスの先頭
                        retname = "DLE"
                    default:
                        retname = ""
                    }
                    //2バイト以上のリターンからの編集
                    if(bytes.count > 1){
                        retname = bytetohexstr(inbyte: bytes)
                        print("16進電文:" + retname)
                        retname = KEISUResponse(strHx: retname)
                    }
                }
                print("Flag:" + flag.description)
                //print("取得内容:" + retname)
                strRtn = retname
                
                //DispatchQueue.main.async {
                //    self.chargerrep = retname
                //}
                //下に移動?
                //20210913 semaphore.signal()
            }
            else {
                NSLog("receiveMessage data nil")
            }
        }
        semaphore.signal() //20210913
    })
    
    semaphore.wait()
    
    return strRtn
}

//<Add 20211115 V1.16>
//受信(計数リード用)
func recv_keisuread(connection: NWConnection) -> String {
    var strRtn: String = ""
    
    let semaphore = DispatchSemaphore(value: 0)
    connection.receive(minimumIncompleteLength: 0, maximumLength: 4096, completion:{(data, context, flag, error) in
        if let error = error {
            NSLog("\(#function), \(error)")
        } else {
            if let data = data {
                let bytes:[UInt8] = [UInt8](data)
                var retname: String = ""
                if(bytes.count > 0){
                    switch bytes[0] {
                    case 0x06: //正常終了
                        retname = "ACK"
                    case 0x18: //異常終了
                        retname = "CAN"
                    case 0x17: //ニアエンプティ
                        retname = "CAN"
                    case 0x15: //通信異常
                        retname = "NAK"
                    case 0x13: //セットはずれ
                        retname = "DC3"
                    case 0x1A: //動作中
                        retname = "SUB"
                    case 0x14: //放出可動作中
                        retname = "DC4"
                    case 0x01: //計数中
                        retname = "SOH"
                    case 0x19: //計数停止中
                        retname = "EM"
                    case 0x07: //動作不可
                        retname = "BEL"
                    case 0x12: //抜き取り待ち
                        retname = "DC2"
                    case 0x10: //レスポンスの先頭
                        retname = "DLE"
                    default:
                        retname = ""
                    }
                    //2バイト以上のリターンからの編集
                    if(bytes.count > 1){
                        retname = bytetohexstr(inbyte: bytes)
                        print("16進電文:" + retname)
                    }
                }
                print("Flag:" + flag.description)
                strRtn = retname
                
            }
            else {
                NSLog("receiveMessage data nil")
            }
        }
        semaphore.signal()
    })
    
    semaphore.wait()
    
    return strRtn
}
//</Add 20211115 V1.16>

//切断
func disconnect(connection: NWConnection)
{
    connection.cancel()
}
//</Add 20210826 釣銭機直接操作>
//<Add 20210930 V1.9>
//バイト配列を文字列にする(数字の範囲のみ処理対象)
func bytetohexstr(inbyte:[UInt8])->String{
    var strHex: String = ""
    for i in 0..<inbyte.count{
        if(inbyte[i] != 0x00){
            strHex += String(format: "%02x", inbyte[i]) + "h"
        }
    }
    return strHex
}

//計数リード時のレスポンスをjson変換する
func KEISUResponse(strHx: String)->String
{
    let aHex: [Substring] = strHx.split(separator: "h");
    var dic = Dictionary<String, String>()
    var amount:Int = 0
    var jstr: String = ""
    
    if (aHex.count < 41) { //<Upd 20211108 40->41>
        return ""
    }
    
    dic["計数情報"] = String(aHex[4].suffix(1))
    dic["計数停止"] = String(aHex[5].suffix(1))
    dic["装置状態"] = String(aHex[6].suffix(1))
    dic["紙幣挿入口情報"] = String(aHex[7].suffix(1))
    dic["紙幣部詳細情報"] = String(aHex[8].suffix(1))
    dic["硬貨投入口情報"] = String(aHex[9].suffix(1))
    dic["硬貨部詳細情報"] = String(aHex[10].suffix(1))
    
    var strMai: String = ""
    strMai = String(aHex[11].suffix(1))
    strMai += String(aHex[12].suffix(1))
    strMai += String(aHex[13].suffix(1))
    dic["10000円"] = strMai
    amount += 10000 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[14].suffix(1))
    strMai += String(aHex[15].suffix(1))
    strMai += String(aHex[16].suffix(1))
    dic["5000円"] = strMai
    amount += 5000 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[17].suffix(1))
    strMai += String(aHex[18].suffix(1))
    strMai += String(aHex[19].suffix(1))
    dic["2000円"] = strMai
    amount += 2000 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[20].suffix(1))
    strMai += String(aHex[21].suffix(1))
    strMai += String(aHex[22].suffix(1))
    dic["1000円"] = strMai
    amount += 1000 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[23].suffix(1))
    strMai += String(aHex[24].suffix(1))
    strMai += String(aHex[25].suffix(1))
    dic["500円"] = strMai
    amount += 500 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[26].suffix(1))
    strMai += String(aHex[27].suffix(1))
    strMai += String(aHex[28].suffix(1))
    dic["100円"] = strMai
    amount += 100 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[29].suffix(1))
    strMai += String(aHex[30].suffix(1))
    strMai += String(aHex[31].suffix(1))
    dic["50円"] = strMai
    amount += 50 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[32].suffix(1))
    strMai += String(aHex[33].suffix(1))
    strMai += String(aHex[34].suffix(1))
    dic["10円"] = strMai
    amount += 10 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[35].suffix(1))
    strMai += String(aHex[36].suffix(1))
    strMai += String(aHex[37].suffix(1))
    dic["5円"] = strMai
    amount += 5 * (Int(strMai) ?? 0)
    
    strMai = String(aHex[38].suffix(1))
    strMai += String(aHex[39].suffix(1))
    strMai += String(aHex[40].suffix(1))
    dic["1円"] = strMai
    amount += Int(strMai) ?? 0
    
    dic["合計金額"] = String(amount)
    
    do {
        // DictionaryをJSONデータに変換
        let jsonData = try JSONSerialization.data(withJSONObject: dic)
        // JSONデータを文字列に変換
        jstr = String(bytes: jsonData, encoding: .utf8)!
        print(jstr)
    } catch (let e) {
        print(e)
    }
    return jstr
}
//<Add 20210930 V1.9>

//スマレジアプリへの入金結果の通知
//smcallback:スマレジ・アプリのコールバック先アドレス
//rslt:処理結果　0:失敗　1:成功
//miss:失敗時のメッセージ
//slip:決済識別子（リクエスト時のものをそのまま返す）
//prc:決済金額
func CallSmaregi(smcallback:String, rslt:String, miss:String, slip:String, prc:String)->String{
    var sma = smcallback + "/?result=" + rslt
    if(!miss.isEmpty){
        sma += "&message=" + miss
    }
    sma += "&slipNumber=" + slip
    sma += "&price=" + prc
    sma += "&payments=[{\"type\":\"現金\",\"price\":"+prc+"}]"
    let encodesma: String = sma.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    guard let url = URL(string: encodesma) else { return ""}
    //    guard let url = URL(string: "http://maps.apple.com") else { return }
    //url scheme でスマレジを起動
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
    return sma
}

//httpリクエスト共通関数（不使用）
func ResponseGet(urlstring:String, completion: @escaping
(String?)->Void){
    
    guard let url = URL(string: urlstring) else { return }
    
    var req = URLRequest(url: url) //可能な限り`NSMutableURLRequest`ではなく`URLRequest`を使う
    req.httpMethod = "GET"
    //req.timeoutInterval = 2
    //waitingなんてフラグは使用しない
    let task = URLSession.shared.dataTask(with: req as URLRequest , completionHandler: { data, res, err  in
        //非nilの値を後で利用するならif-letを使用した方が良い
        if let data = data, err == nil {
            //print(data as NSData, res!.textEncodingName ?? "encoding unknown") //デバッグ用
            let text: String? = String(data: data, encoding: .utf8) //可能な限り`NSString`ではなく`String`を利用する
            DispatchQueue.main.async(execute: {
                var result: String
                result = text!
                //結果は必ず完了ハンドラーの中で使う
                result = result.uppercased()
                //完了ハンドラーの中で自前に完了ハンドラーを呼び出す
                completion(result)
            })
        } else {
            //エラーを黙って無視しない
            if let error = err {
                print(error)
            }
            if data == nil {
                print("data is nil")
            }
            DispatchQueue.main.async(execute: {
                //何も書かれていなかったが、エラー時にはnilを完了ハンドラーに渡すことにする
                completion(nil)
            })
        }
    })
    task.resume()
}

func ReturnMessage(replay: String)->String{
    var strRtn: String = replay
    if replay.starts(with: "{"){
        let jsonString: String = replay
        let personalData: Data =  jsonString.data(using: String.Encoding.utf8)!
        
        do {
            // パースする
            let items = try JSONSerialization.jsonObject(with: personalData) as! Dictionary<String, Any>
            let mes = items["message"] as? String ?? ""
            strRtn = mes
        } catch {
            print(error)
        }
    }
    return strRtn
}
//httpリクエスト共通関数(同期制御用)
func ResponseGetNosync(urlstring:String, completion: @escaping
(String?)->Void){
    
    guard let url = URL(string: urlstring) else { return }
    
    var req = URLRequest(url: url) //可能な限り`NSMutableURLRequest`ではなく`URLRequest`を使う
    req.httpMethod = "GET"
    //req.timeoutInterval = 2
    //無効の様
    //req.setValue("close", forHTTPHeaderField: "Connection")
    //if let headers = req.allHTTPHeaderFields{
    //     print("\(headers)")
    //}
    
    //waitingなんてフラグは使用しない
    let task = URLSession.shared.dataTask(with: req as URLRequest , completionHandler: { data, res, err  in
        //非nilの値を後で利用するならif-letを使用した方が良い
        if let data = data, err == nil {
            //print(data as NSData, res!.textEncodingName ?? "encoding unknown") //デバッグ用
            
            let text: String? = String(data: data, encoding: .utf8) //可能な限り`NSString`ではなく`String`を利用する
            var result: String
            result = text!
            //完了ハンドラーの中で自前に完了ハンドラーを呼び出す
            completion(result)
        } else {
            //エラーを黙って無視しない
            if let error = err {
                print(error)
            }
            if data == nil {
                print("data is nil")
            }
            //何も書かれていなかったが、エラー時にはnilを完了ハンドラーに渡すことにする
            completion(nil)
        }
    })
    task.resume()
}

//釣り銭機通信ステータス要求（非同期）
func ENQSend(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/enqsend"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}

//サーバー画面リセット（同期）
func ResetdispRtn()->String{
    var rtn: String = ""
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/resetdisp"
    
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            // ここに書くとhungupする semaphore.signal()
        } else {
            print("通信エラー")
        }
        semaphore.signal() //ここならハングしない
    })
    semaphore.wait()
    return rtn
}
//確認状態設定（同期）
func ConfsetRtn(confirmstatus: String, announce: String)->String{
    var rtn: String = ""
    let profile = UserProfile()
    var chngrreq = "http://" + profile.changerappip + "/confset" + "?confirmstatus=" + confirmstatus + "&announce=" + announce
    chngrreq = chngrreq.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            // ここに書くとhungupする semaphore.signal()
        } else {
            print("通信エラー")
        }
        semaphore.signal() //ここならハングしない
    })
    semaphore.wait()
    return rtn
}

//釣り銭機通信ステータス要求（同期）
func ENQSendRtn()->String{
    var rtn: String = ""
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/enqsend"
    
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            // ここに書くとhungupする semaphore.signal()
        } else {
            print("通信エラー")
        }
        semaphore.signal() //ここならハングしない
    })
    semaphore.wait()
    return rtn
}

//釣り銭機通信停止・初期化（非同期）
func EOTSend(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/eotsend"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}

//釣り銭機精査（同期）
//精査は釣銭機内金種ごとの枚数などの状態を示す
func SeisaRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/seisa"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}

//釣り銭機計数開始（同期）
func KeisuStartonRtn(price: String, customercode: String, customername: String)->String{
    let profile = UserProfile()
    var chngrreq: String = "http://" + profile.changerappip + "/keisustart" + "?price=" + price
    
    if (customercode.count > 0){
        chngrreq += "&customercode="
        chngrreq += customercode
    }
    if (customername.count > 0){
        chngrreq += "&customername=" + customername
    }
    chngrreq = chngrreq.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}

//釣り銭機計数リード(非同期)
func KeisuRead(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisuread"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}
//釣り銭機計数リード（同期）
func KeisuReadRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisuread"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}

//釣り銭機計数停止（予約）(非同期)
func KeisuStop(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisustop"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}
//釣り銭機計数停止（予約）（同期）
func KeisuStopRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisustop"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}

//釣り銭機計数終了（非同期）
func KeisuEnd(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisuend"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}
//釣り銭機計数終了（同期）
func KeisuEndRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisuend"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}
//<Add 20211101 V1.12> 表示側に不具合が発生する為不採用
//釣り銭機計数リセット（同期）
func KeisuResetRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisureset"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}
//</Add 20211101 V1.12>

//釣り銭機計数再開（非同期）
func KeisuRestart(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/keisurestart"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}

//釣銭放出(非同期)
func Payout(charge: String){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/payout?charge=" + charge
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}
//釣銭放出（同期）
func PayoutRtn(charge: String)->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/payout?charge=" + charge
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}
//<Add 20210914 ver1.5>
//投入金放出（同期）
func CancelPayoutRtn()->String{
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/cancelpayout"
    var rtn: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    
    ResponseGetNosync(urlstring: chngrreq,completion: {result in
        if let result = result {
            rtn = result
            //結果を出力
            print(result)
            
        } else {
            print("通信エラー")
        }
        semaphore.signal()
    })
    semaphore.wait()
    /* switch semaphore.wait(timeout:  .now() + 4){
     case .success:
     return rtn
     case .timedOut:
     return rtn
     }
     */
    return rtn //順序を守る処理をしないと""が返る
}
//</Add 20210914 ver1.5>

//リセット（非同期）
func Reset(){
    let profile = UserProfile()
    let chngrreq = "http://" + profile.changerappip + "/resetcharger"
    guard let url = URL(string: chngrreq) else { return }
    
    //URLを生成
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    //request.timeoutInterval = 2
    //Requestを生成
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
        guard let data = data else { return }
        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [])  // DataをJsonに変換
            print(object)
        } catch let error {
            print(error)
        }
    }
    task.resume()
}


//プレビュー表示用
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
