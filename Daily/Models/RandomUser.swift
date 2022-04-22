//
//  RandomUser.swift
//  Daily
//
//  Created by kasoly on 2022/4/13.
//

import Foundation


struct RandomUser: Identifiable, Decodable {
    var id: Int
    var avatar: String
    var first_name: String
    var uid: String
}

class RandomUserModel: ObservableObject {
    @Published var randomUser: RandomUser = RandomUser(id: 0, avatar: "", first_name: "匿名", uid: "1")
    
    @MainActor
    func fetchRandomUser() async {
        do {
            let url = URL(string: "https://random-data-api.com/api/users/random_user")!
            let (data, _) = try await URLSession.shared.data(from: url)
            randomUser = try JSONDecoder().decode(RandomUser.self, from: data)
            UserDefaults.SuggestAccount.set(value: randomUser.first_name,forKey: .nickname)
            UserDefaults.SuggestAccount.set(value: randomUser.avatar,forKey: .avatar)
        } catch {
            print("Error")
        }
    }
}
