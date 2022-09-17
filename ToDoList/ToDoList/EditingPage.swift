//
//  EditingPage.swift
//  ToDoList
//
//  Created by Moon on 2020/7/17.
//  Copyright © 2020 Moon. All rights reserved.
//

import SwiftUI

struct EditingPage: View {
    
    @EnvironmentObject var UserData: ToDo
    
    @State var title: String = ""
    @State var duedate: Date = Date()
    @State var isFavorite = false
    @State var isLoop = false
    
    var id: Int? = nil
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("事项")) {
                    TextField("事项内容", text: self.$title)
                    DatePicker(selection: self.$duedate, label: { Text("截止时间") })
                }
                
                Section {
                    Toggle(isOn: self.$isFavorite) {
                    Text("收藏")
                    }
                }
                
                Section {
                    Toggle(isOn: self.$isLoop) {
                        Text("重复")
                    }
                }
                
                Section {
                    Button(action: {
                        if self.id == nil {
                            self.UserData.add(data: SingleToDo(title: self.title, duedate: self.duedate, isFavorite: self.isFavorite, isLoop: self.isLoop))
                        }
                        else {
                            self.UserData.edit(id: self.id!, data: SingleToDo(title: self.title, duedate: self.duedate, isFavorite: self.isFavorite, isLoop: self.isLoop))
                        }
                        self.presentation.wrappedValue.dismiss()
                        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                            impactHeavy.impactOccurred()
                    }) {
                        Text("确认")
                    }
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("取消")
                    }
                    
                }
                
            }
        .navigationBarTitle("添加")
        }
    }
}

struct EditingPage_Previews: PreviewProvider {
    static var previews: some View {
        EditingPage()
    }
}
