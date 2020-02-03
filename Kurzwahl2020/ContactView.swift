//
//  ContactView.swift
//  Kurzwahl2020
//
//  Created by Vogel, Andreas on 22.01.20.
//  Copyright © 2020 Vogel, Andreas. All rights reserved.
//

import SwiftUI
import Contacts
import Combine

struct ContactView: View {
    @EnvironmentObject var editNavigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    
    let contacts = contactReader().getUniqueContacts()
    
    var body: some View {
        VStack{
            List {
                ForEach(contacts) { person  in
                    contactRow(person: person)
                }
            }
        }
    }
}



struct contactRow: View {
    var person : myContact
    @EnvironmentObject var navigation: NavigationStack
    @EnvironmentObject var editViewState : EditViewState
    @EnvironmentObject var datamodel : contactReader
    
    var body: some View {
        HStack {
            Button(action: {
                if (self.datamodel.getNumberOfPhoneNumbers(forContactName: self.person.name) == 1){
                    self.editViewState.userSelectedName = self.person.name
                    self.editViewState.userSelectedNumber = self.person.phoneNumber
                    self.navigation.unwind()
                } else {
                    self.editViewState.userSelectedName = self.person.name
                    self.editViewState.userSelectedNumber = self.person.phoneNumber
                    self.navigation.unwind()
                    
                }
            })
            {
                Text(person.name)
            }.buttonStyle(PlainButtonStyle())
            Spacer()
//            Text(person.label)
            

            if person.imageDataAvailable == true {
                Image(uiImage: UIImage(data: person.thumbnailImageData)! ).resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle().size(width:50, height:50 ) )
                    .aspectRatio(contentMode: ContentMode.fit)
            }
        }
    }
}






func presentSettingsActionSheet() {
    let alert = UIAlertController(title: "Permission to Contacts", message: "This app needs access to contacts in order to ...", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Go to Settings", style: .default) { _ in
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url)
    })
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    //        present(alert, animated: true)
}



struct ContactView_Previews: PreviewProvider {
    static var previews: some View {
        ContactView()
    }
}



