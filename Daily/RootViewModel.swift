//
//  RootViewShow.swift
//  Daily
//
//  Created by kasoly on 2022/3/24.
//

import Foundation


class RootViewModel {
    
    init(){}
    
    lazy var HomeVM: HomeViewModel = {
        return HomeViewModel()
    }()
   
    lazy var TopicVM: TopicViewModel = {
        return TopicViewModel()
    }()
    
}
