//
//  CloudErrorCodes.swift
//
//  Template created by Pete Maiser, July 2024 through August 2025
//  Modified by Pete Maiser, Fast Five Products LLC, on 2/3/26.
//      Template v0.2.5 (updated) — Fast Five Products LLC's public AGPL template.
//
//  Copyright © 2025 Fast Five Products LLC. All rights reserved.
//
//  This file is part of a project licensed under the GNU Affero General Public License v3.0.
//  See the LICENSE file at the root of this repository for full terms.
//
//  An exception applies: Fast Five Products LLC retains the right to use this code and
//  derivative works in proprietary software without being subject to the AGPL terms.
//  See LICENSE-EXCEPTIONS.md for details.
//
//  For licensing inquiries, contact: licenses@fastfiveproducts.llc
//


import Foundation

enum AuthError: Error, LocalizedError {
    case invalidInput
    case emailLinkInvalid
    case signInInputsNotFound
    case userNotFound
    case userIdNotFound
    
    var errorDescription: String? {
        switch self {
            case .invalidInput:
                return NSLocalizedString("Missing Data, please check all fields and try again", comment: "User Input Error")
            case .emailLinkInvalid:
                return NSLocalizedString("Invalid link received from cloud in user create process, please try again", comment: "Cloud Services Communications Error")
            case .userNotFound:
                return NSLocalizedString("Could not complete sign in as user does not exist", comment: "User does not exist")
            case .signInInputsNotFound:
                return NSLocalizedString("Could not complete sign in, please go to sign in page and try again", comment: "Unexpected Internal Error")
            case .userIdNotFound:
                return NSLocalizedString("Completed sign in but User Id not found, some features may not work correctly", comment: "Unexpected Cloud Services Error")
        }
    }
}

enum AccountCreationError: Error, LocalizedError {
    case invalidInput
    case userIdNotFound
    case userAccountCreationIncomplete(Error)
    case userAccountCompletionFailed(Error)
    case userDisplayNameCreationFailed
    case setUserDisplayNameFailed

    var errorDescription: String? {
        switch self {
            case .invalidInput:
                return NSLocalizedString("Missing Data, please check all fields and try again", comment: "User Input Error")
            case .userIdNotFound:
                return NSLocalizedString("Could not complete user create process, please try again", comment: "Unexpected Cloud Services Error")
            case let .userAccountCreationIncomplete(error):
                return NSLocalizedString("Error in user profile creation, please try again.  Error: \(error)", comment: "Cloud Services Communications Error")
            case let .userAccountCompletionFailed(error):
                return NSLocalizedString("Error completing user account setup, please try again.  Error: \(error)", comment: "Cloud Services Communications Error")
            case .userDisplayNameCreationFailed:
                return NSLocalizedString("Error in user display name creation, default used; you can change display name later in your user profile.", comment: "Cloud Services Communications Error")
            case .setUserDisplayNameFailed:
                return NSLocalizedString("Error in user display name update, default used; you can change display name later in your user profile.", comment: "Cloud Services Communications Error")
        }
    }
}

enum UserProfileError: Error, LocalizedError {
    case userProfileFetch(Error)
    
    var errorDescription: String? {
        switch self {
        case let .userProfileFetch(error):
            return NSLocalizedString("Error retrieving user profile, some features may not work correctly.  Error: \(error)", comment: "Cloud Services Communications Error")
        }
    }
}

enum FetchDataError: Error, LocalizedError {
    case invalidFunctionInput
    case invalidCloudData, cloudDataConversionError
    case userDataNotFound, userDataDuplicatesFound
    
    var errorDescription: String? {
        switch self {
            case .invalidFunctionInput:
                return NSLocalizedString("Invalid function input.", comment: "Unexpected Internal Error")
                
            case .invalidCloudData:
                return NSLocalizedString("Required cloud data was not received, some features may not work correctly, try again later.", comment: "Cloud Services Data Validation Error")
            case .cloudDataConversionError:
                return NSLocalizedString("Cloud data conversion error, try again later.", comment: "Cloud Services Data Format Error")
                
            case .userDataNotFound:
                return NSLocalizedString("User data not found.", comment: "Unexpected Cloud Services Error")
            case .userDataDuplicatesFound:
                return NSLocalizedString("Duplicates found in user data.", comment: "Unexpected Cloud Services Error")
        }
    }
}

enum UpsertDataError: Error, LocalizedError {
    case invalidFunctionInput, unexpectedInternalError
    case objectConversionError
    
    var errorDescription: String? {
        switch self {
            case .invalidFunctionInput:
                return NSLocalizedString("Invalid function input, check fields and try again.", comment: "Internal Error")
            case .unexpectedInternalError:
                return NSLocalizedString("Unknown Internal Error, try again.", comment: "Internal Error")
                
            case .objectConversionError:
                return NSLocalizedString("Data Conversion Error in Data Translation for Cloud Integration.", comment: "Cloud Data Conversion Error")
        }
    }
}

enum ObjectStoreError: Error, LocalizedError {
    case invalidFunctionInput, unexpectedInternalError
    case objectConversionError, unknownCloudError
    case storeNotLoaded, storeNotInitalized, objectNotAvailable
    
    var errorDescription: String? {
        switch self {
            case .invalidFunctionInput:
                return NSLocalizedString("Invalid function input.", comment: "Internal Error")
            case .unexpectedInternalError:
                return NSLocalizedString("Unknown Internal Error, try again.", comment: "Internal Error")
                
            case .objectConversionError:
                return NSLocalizedString("Data Conversion Error in Data Translation for Cloud Integration.", comment: "Cloud Data Conversion Error")
            case .unknownCloudError:
                return NSLocalizedString("Unknown Cloud Error, try again.", comment: "Cloud Services Error")
                
            case .storeNotLoaded:
                return NSLocalizedString("Object requested from a store that has not been loaded.", comment: "Internal Error")
            case .storeNotInitalized:
                return NSLocalizedString("Create object requested from a store that has not been initialized.", comment: "Internal Error")
            case .objectNotAvailable:
                return NSLocalizedString("Requested Object not found locally.", comment: "Object Not Found")
        }
    }
}

enum ApplicationWarning: Error, LocalizedError {
    case dataNotFound
    
    var errorDescription: String? {
        switch self {
            case .dataNotFound:
                return NSLocalizedString("Data not available, check connection, or try to sign in again.", comment:"Impaired Functionality")
            }
    }
}

