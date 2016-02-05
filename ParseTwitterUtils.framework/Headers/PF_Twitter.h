<<<<<<< HEAD
/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import <Foundation/Foundation.h>

#import <Parse/PFConstants.h>

NS_ASSUME_NONNULL_BEGIN

@class BFTask<__covariant BFGenericType>;

/**
=======
//
//  PF_Twitter.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Parse/PFNullability.h>

PF_ASSUME_NONNULL_BEGIN

@class BFTask;

/*!
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 The `PF_Twitter` class is a simple interface for interacting with the Twitter REST API,
 automating sign-in and OAuth signing of requests against the API.
 */
@interface PF_Twitter : NSObject

<<<<<<< HEAD
/**
 Consumer key of the application that is used to authorize with Twitter.
 */
@property (nullable, nonatomic, copy) NSString *consumerKey;

/**
 Consumer secret of the application that is used to authorize with Twitter.
 */
@property (nullable, nonatomic, copy) NSString *consumerSecret;

/**
 Auth token for the current user.
 */
@property (nullable, nonatomic, copy) NSString *authToken;

/**
 Auth token secret for the current user.
 */
@property (nullable, nonatomic, copy) NSString *authTokenSecret;

/**
 Twitter user id of the currently signed in user.
 */
@property (nullable, nonatomic, copy) NSString *userId;

/**
 Twitter screen name of the currently signed in user.
 */
@property (nullable, nonatomic, copy) NSString *screenName;

/**
 Displays an auth dialog and populates the authToken, authTokenSecret, userId, and screenName properties
 if the Twitter user grants permission to the application.

 @return The task, that encapsulates the work being done.
 */
- (BFTask *)authorizeInBackground;

/**
 Displays an auth dialog and populates the authToken, authTokenSecret, userId, and screenName properties
=======
/*!
 @abstract Consumer key of the application that is used to authorize with Twitter.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *consumerKey;

/*!
 @abstract Consumer secret of the application that is used to authorize with Twitter.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *consumerSecret;

/*!
 @abstract Auth token for the current user.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *authToken;

/*!
 @abstract Auth token secret for the current user.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *authTokenSecret;

/*!
 @abstract Twitter user id of the currently signed in user.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *userId;

/*!
 @abstract Twitter screen name of the currently signed in user.
 */
@property (PF_NULLABLE_PROPERTY nonatomic, copy) NSString *screenName;

/*!
 @abstract Displays an auth dialog and populates the authToken, authTokenSecret, userId, and screenName properties
 if the Twitter user grants permission to the application.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)authorizeInBackground;

/*!
 @abstract Displays an auth dialog and populates the authToken, authTokenSecret, userId, and screenName properties
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 if the Twitter user grants permission to the application.

 @param success Invoked upon successful authorization.
 @param failure Invoked upon an error occurring in the authorization process.
 @param cancel Invoked when the user cancels authorization.
 */
<<<<<<< HEAD
- (void)authorizeWithSuccess:(nullable void (^)(void))success
                     failure:(nullable void (^)(NSError *__nullable error))failure
                      cancel:(nullable void (^)(void))cancel;

/**
 Adds a 3-legged OAuth signature to an `NSMutableURLRequest` based
 upon the properties set for the Twitter object.

 Use this function to sign requests being made to the Twitter API.

 @param request Request to sign.
 */
- (void)signRequest:(nullable NSMutableURLRequest *)request;

@end

NS_ASSUME_NONNULL_END
=======
- (void)authorizeWithSuccess:(PF_NULLABLE void (^)(void))success
                     failure:(PF_NULLABLE void (^)(NSError *PF_NULLABLE_S error))failure
                      cancel:(PF_NULLABLE void (^)(void))cancel;

/*!
 @abstract Adds a 3-legged OAuth signature to an `NSMutableURLRequest` based
 upon the properties set for the Twitter object.

 @discussion Use this function to sign requests being made to the Twitter API.

 @param request Request to sign.
 */
- (void)signRequest:(PF_NULLABLE NSMutableURLRequest *)request;

@end

PF_ASSUME_NONNULL_END
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
