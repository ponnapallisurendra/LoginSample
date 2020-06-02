//
//  TestExampleUITests.swift
//  TestExampleUITests
//
//  Created by Japp Tech on 02/01/20.
//  Copyright © 2020 Japp Tech. All rights reserved.
//

import XCTest

class TestExampleUITests: XCTestCase {

    let app = XCUIApplication()
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // UI tests must launch the application that they test.

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        login(email: "venkat@gmail.com", password: "8500764995")
        
        let mainTable = app.tables
        let predicate = NSPredicate(format: "exists == true")
       // let completedPercentageLabel = app.staticTexts["100%"]
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: mainTable)
        _ = XCTWaiter().wait(for: [expectation], timeout:5)
        
        XCTAssertTrue(mainTable.staticTexts["Leanne Graham,Bret"].exists)


    }
    func waitForElementToAppear(_ element: XCUIElement) -> Bool {
        let predicate = NSPredicate(format: "exists == true")
        let expectations = expectation(for: predicate, evaluatedWith: element,
                                      handler: nil)

        let result = XCTWaiter().wait(for: [expectations], timeout: 5)
        return result == .completed
    }
    func login(email:String, password : String){
        
        //Email
        let emailTextField = app.textFields["User Name"]
//        if let emailString = emailTextField.value as? String, emailString == email{
//            //Do nothing if email already present
//            print(emailTextField.value!)
//        }else{
        
            emailTextField.tap()
            emailTextField.clearText()
            emailTextField.typeText(email)
       // }
        
        //Password
        let passwordSecureTextField = app.textFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.clearText()
        passwordSecureTextField.typeText(password)
        
        //Login
        let loginButton = app.buttons["LOGIN"]
        loginButton.tap()
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
extension XCUIElement {
    
    func clearAndEnterText(text: String) {
        self.tap()
        clearText()
        self.typeText(text)
    }
    
    func clearText() {
        guard let stringValue = self.value as? String else { return }
        
        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        self.typeText(deleteString)
    }
}
