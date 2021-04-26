//
//  OrderTableViewController.swift
//  DinInLiao
//
//  Created by LIU SHANG WEI on 2021/4/21.
//

import UIKit

class OrderTableViewController: UITableViewController {
    var pickView = UIPickerView()
    let item: Record
    var size = ""
    var sugar = ""
    var temp = ""
    var plus = ""
    @IBOutlet weak var sugarTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var tempTextField: UITextField!
    @IBOutlet weak var goodsNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var plusTextField: UITextField!
    @IBOutlet weak var addShoppingCartButton: UIButton!
    required init?(coder: NSCoder, item: Record) {
        self.item = item
        super.init(coder: coder)!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //宣告要inputView要設定為pickerView的textField
    var pickerField:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeTextField.delegate = self
        sugarTextField.delegate = self
        tempTextField.delegate = self
        plusTextField.delegate = self
        goodsNameLabel.text = item.fields.goodsName
        descriptionLabel.text = item.fields.description
    }
    
    func initPickerView(touchAt sender:UITextField){
        pickView = UIPickerView()
        pickView.tag = 0
        if sender == sizeTextField {
            pickView.tag = 0
        } else if sender == sugarTextField {
            pickView.tag = 1
        } else if sender == tempTextField {
            pickView.tag = 2
        } else if sender == plusTextField {
            pickView.tag = 3
        }
        pickView.delegate = self
        pickView.dataSource = self
        
        //初始化pickerView上方的toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        //加入toolbar的按鈕跟中間的空白
        let doneButton = UIBarButtonItem(title: "確認", style: .plain, target: self, action: #selector(submit))
        //將doneButton設定跟pickerView一樣的tag，submit方法裡可以比對要顯示哪個textField的text
        doneButton.tag = pickView.tag
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        //設定toolBar可以使用
        toolBar.isUserInteractionEnabled = true
        //初始化textField，要先加入subView，才能設定他的inputView跟inputAccessoryView
        pickerField = UITextField(frame: CGRect.zero)
        view.addSubview(pickerField)
        pickerField.inputView = pickView
        pickerField.inputAccessoryView = toolBar
        //彈出pickerField
        pickerField.becomeFirstResponder()
        var index = 0
        if pickView.tag == 0 {
            index = Size.init().type.firstIndex(of: size) ?? 0
        } else if pickView.tag == 1 {
            index = Sugar.init().level.firstIndex(of: sugar) ?? 0
        } else if pickView.tag == 2 {
            index = Temp.init().level.firstIndex(of: temp) ?? 0
        } else if pickView.tag == 3 {
            index = Plus.init().type.firstIndex(of: plus) ?? 0
        }
        pickView.selectRow(index, inComponent: 0, animated: false)
        
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 1
//    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func dismissKeyboard(_ sender: Any) {
    }
    @IBAction func addShoppingCart(_ sender: Any) {
        // 檢查選項
        guard self.checkOption() else { return }
        let controller = UIAlertController(title: "加入訂單嗎?", message: "", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "確定", style: .default) { (_) in
            
            
            // 將訂單上傳至airtable
            let order = Order(records: [.init(fields: .init(orderName: self.nameTextField.text ?? "", goodsName: self.goodsNameLabel.text ?? "", size: self.sizeTextField.text ?? "", sugar: self.sugarTextField.text ?? "", temp: self.tempTextField.text ?? "", plus: self.plusTextField.text ?? ""))])
            let url = URL(string: "https://api.airtable.com/v0/appzbjom7lfkVVipd/OrderList")!
            var request = URLRequest(url: url)
            request.setValue("Bearer keyl6pn82pKoEYem1", forHTTPHeaderField: "Authorization")
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            request.httpBody = try? encoder.encode(order)
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                // 檢查是否上傳成功
                if let res = response as? HTTPURLResponse,res.statusCode == 200 {
                    print("success")
                    if let data = data,
                       let content = String(data: data, encoding: .utf8) {
                        print(content)
                    }
                } else {
                    print(error)
                }
                
            }.resume()
            self.orderEnd()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        controller.addAction(confirmAction)
        controller.addAction(cancelAction)
        present(controller, animated: true, completion: nil)
    }
    func orderEnd() {
        let finallyController = UIAlertController(title: "訂單", message: "新增成功!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        finallyController.addAction(okAction)
        present(finallyController, animated: true, completion: nil)
    }
    func checkOption() -> Bool {
        var check = true
        var message = ""
        if nameTextField.text == "" || nameTextField.text == nil {
            message = "請填寫訂購人姓名!"
            check = false
        } else if sizeTextField.text == "" || sizeTextField.text == nil {
            message = "請選取容量!"
            check = false
        } else if sugarTextField.text == "" || sugarTextField.text == nil {
            message = "請選取甜度!"
            check = false
        } else if tempTextField.text == "" || tempTextField.text == nil {
            message = "請選取溫度!"
            check = false
        }
        if check == false {
            let controller = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true, completion: nil)
        }
        return check
    }
    //設定toolBar的按鈕事件
    @objc func cancel(){
        self.pickerField?.resignFirstResponder()
    }
    @objc func submit(sender: UIBarButtonItem){
        let pickerViewTag = sender.tag
        if pickerViewTag == 0 {
            DispatchQueue.main.async { [self] in
                if size == "" {
                    let row = pickView.selectedRow(inComponent: 0)
                    size = Size.init().type[row]
                }
                sizeTextField.text = size
                self.pickerField?.resignFirstResponder()
            }
        } else if pickerViewTag == 1 {
            DispatchQueue.main.async { [self] in
                if sugar == "" {
                    let row = pickView.selectedRow(inComponent: 0)
                    sugar = Sugar.init().level[row]
                }
                sugarTextField.text = sugar
                self.pickerField?.resignFirstResponder()
            }
        } else if pickerViewTag == 2 {
            DispatchQueue.main.async { [self] in
                if temp == "" {
                    let row = pickView.selectedRow(inComponent: 0)
                    temp = Temp.init().level[row]
                }
                tempTextField.text = temp
                self.pickerField?.resignFirstResponder()
            }
        } else if pickerViewTag == 3 {
            DispatchQueue.main.async { [self] in
                if plus == "" {
                    let row = pickView.selectedRow(inComponent: 0)
                    plus = Plus.init().type[row]
                }
                plusTextField.text = plus
                self.pickerField?.resignFirstResponder()
            }
        }
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OrderTableViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.initPickerView(touchAt: textField)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //按return會關掉picker view
        textField.resignFirstResponder()
        return true
    }
}

extension OrderTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //判斷pickerView的tag值來回傳有幾個component
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //判斷pickerView的tag值以及component來回傳有幾個row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return Size.init().type.count
        } else if pickerView.tag == 1 {
            return Sugar.init().level.count
        } else if pickerView.tag == 2 {
            return Temp.init().level.count
        } else if pickerView.tag == 3 {
            return Plus.init().type.count
        }
        return 0
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return Size.init().type[row]
        } else if pickerView.tag == 1 {
            return Sugar.init().level[row]
        } else if pickerView.tag == 2 {
            return Temp.init().level[row]
        } else if pickerView.tag == 3 {
            return Plus.init().type[row]
        }
        return ""
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //將使用者選到的資料一對應的component跟row取得資料後指定給變數
        if pickerView.tag == 0 {
            self.size = Size.init().type[row]
        } else if pickerView.tag == 1 {
            self.sugar = Sugar.init().level[row]
        } else if pickerView.tag == 2 {
            self.temp = Temp.init().level[row]
        } else if pickerView.tag == 3 {
            self.plus = Plus.init().type[row]
        }
    }
    
}
