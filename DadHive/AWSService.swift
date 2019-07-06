//
//  AWSService.swift
//  PopViewers
//
//  Created by Michael Westbrooks II on 5/13/18.
//  Copyright © 2018 MVPGurus. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore

let awsIDPool = ""

class AWSService {
    static let shared = AWSService()
    private init() {
        print("\(kAppName) | AWS Service Initialized")
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast1,
                                                                identityPoolId: awsIDPool)
        let configuration = AWSServiceConfiguration(region:.USEast1,
                                                    credentialsProvider:credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
}
