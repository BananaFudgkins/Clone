<<<<<<< HEAD
/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
=======
//
//  PFFacebookUtils.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

#import <Foundation/Foundation.h>

#import <Bolts/BFTask.h>

<<<<<<< HEAD
#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>

#import <FBSDKCoreKit/FBSDKAccessToken.h>

#if TARGET_OS_IOS
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#endif

NS_ASSUME_NONNULL_BEGIN

/**
 The `PFFacebookUtils` class provides utility functions for using Facebook authentication with `PFUser`s.
=======
#import <FBSDKCoreKit/FBSDKAccessToken.h>

#import <FBSDKLoginKit/FBSDKLoginManager.h>

#import <Parse/PFConstants.h>
#import <Parse/PFNullability.h>
#import <Parse/PFUser.h>

PF_ASSUME_NONNULL_BEGIN

/*!
 The `PFFacebookUtils` class provides utility functions for using Facebook authentication with <PFUser>s.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @warning This class supports official Facebook iOS SDK v4.0+ and is available only on iOS.
 */
@interface PFFacebookUtils : NSObject

///--------------------------------------
/// @name Interacting With Facebook
///--------------------------------------

<<<<<<< HEAD
/**
 Initializes Parse Facebook Utils.

 You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file
 as described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

 @warning You must invoke this in order to use the Facebook functionality in Parse.

 @param launchOptions The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
 */
+ (void)initializeFacebookWithApplicationLaunchOptions:(nullable NSDictionary *)launchOptions;

#if TARGET_OS_IOS
/**
 `FBSDKLoginManager` provides methods for configuring login behavior, default audience
 and managing Facebook Access Token.
 
 @warning This method is available only on iOS.

 @return An instance of `FBSDKLoginManager` that is used by `PFFacebookUtils`.
 */
+ (FBSDKLoginManager *)facebookLoginManager;
#endif
=======
/*!
 @abstract Initializes Parse Facebook Utils.

 @discussion You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file
 as described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

 @warning You must invoke this in order to use the Facebook functionality in Parse.
 
 @param launchOptions The launchOptions as passed to [UIApplicationDelegate application:didFinishLaunchingWithOptions:].
 */
+ (void)initializeFacebookWithApplicationLaunchOptions:(PF_NULLABLE NSDictionary *)launchOptions;

/*!
 @abstract `FBSDKLoginManager` provides methods for configuring login behavior, default audience
 and managing Facebook Access Token.

 @returns An instance of `FBSDKLoginManager` that is used by `PFFacebookUtils`.
 */
+ (FBSDKLoginManager *)facebookLoginManager;
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

///--------------------------------------
/// @name Logging In
///--------------------------------------

<<<<<<< HEAD
/**
 *Asynchronously* logs in a user using Facebook with read permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.

 @param permissions Array of read permissions to use.

 @return The task that has will a have `result` set to `PFUser` if operation succeeds.
 */
+ (BFTask<PFUser *> *)logInInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions;

/**
 *Asynchronously* logs in a user using Facebook with read permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.
=======
/*!
 @abstract *Asynchronously* logs in a user using Facebook with read permissions.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.

 @param permissions Array of read permissions to use.

 @returns The task that has will a have `result` set to <PFUser> if operation succeeds.
 */
+ (BFTask *)logInInBackgroundWithReadPermissions:(PF_NULLABLE NSArray *)permissions;

/*!
 @abstract *Asynchronously* logs in a user using Facebook with read permissions.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @param permissions Array of read permissions to use.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(PFUser *user, NSError *error)`.
 */
<<<<<<< HEAD
+ (void)logInInBackgroundWithReadPermissions:(nullable NSArray<NSString *> *)permissions
                                       block:(nullable PFUserResultBlock)block;

/**
 *Asynchronously* logs in a user using Facebook with publish permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.

 @param permissions Array of publish permissions to use.

 @return The task that has will a have `result` set to `PFUser` if operation succeeds.
 */
+ (BFTask<PFUser *> *)logInInBackgroundWithPublishPermissions:(nullable NSArray<NSString *> *)permissions;

/**
 *Asynchronously* logs in a user using Facebook with publish permissions.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.
=======
+ (void)logInInBackgroundWithReadPermissions:(PF_NULLABLE NSArray *)permissions
                                       block:(PF_NULLABLE PFUserResultBlock)block;

/*!
 @abstract *Asynchronously* logs in a user using Facebook with publish permissions.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.

 @param permissions Array of publish permissions to use.

 @returns The task that has will a have `result` set to <PFUser> if operation succeeds.
 */
+ (BFTask *)logInInBackgroundWithPublishPermissions:(PF_NULLABLE NSArray *)permissions;

/*!
 @abstract *Asynchronously* logs in a user using Facebook with publish permissions.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @param permissions Array of publish permissions to use.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(PFUser *user, NSError *error)`.
 */
<<<<<<< HEAD
+ (void)logInInBackgroundWithPublishPermissions:(nullable NSArray<NSString *> *)permissions
                                          block:(nullable PFUserResultBlock)block;

/**
 *Asynchronously* logs in a user using given Facebook Acess Token.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.

 @param accessToken An instance of `FBSDKAccessToken` to use when logging in.

 @return The task that has will a have `result` set to `PFUser` if operation succeeds.
 */
+ (BFTask<PFUser *> *)logInInBackgroundWithAccessToken:(FBSDKAccessToken *)accessToken;

/**
 *Asynchronously* logs in a user using given Facebook Acess Token.

 This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a `PFUser`.
=======
+ (void)logInInBackgroundWithPublishPermissions:(PF_NULLABLE NSArray *)permissions
                                          block:(PF_NULLABLE PFUserResultBlock)block;

/*!
 @abstract *Asynchronously* logs in a user using given Facebook Acess Token.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.

 @param accessToken An instance of `FBSDKAccessToken` to use when logging in.

 @returns The task that has will a have `result` set to <PFUser> if operation succeeds.
 */
+ (BFTask *)logInInBackgroundWithAccessToken:(FBSDKAccessToken *)accessToken;

/*!
 @abstract *Asynchronously* logs in a user using given Facebook Acess Token.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @param accessToken An instance of `FBSDKAccessToken` to use when logging in.
 @param block       The block to execute when the log in completes.
 It should have the following signature: `^(PFUser *user, NSError *error)`.
 */
+ (void)logInInBackgroundWithAccessToken:(FBSDKAccessToken *)accessToken
<<<<<<< HEAD
                                   block:(nullable PFUserResultBlock)block;
=======
                                   block:(PF_NULLABLE PFUserResultBlock)block;
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

///--------------------------------------
/// @name Linking Users
///--------------------------------------

<<<<<<< HEAD
/**
 *Asynchronously* links Facebook with read permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
/*!
 @abstract *Asynchronously* links Facebook with read permissions to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of read permissions to use when logging in with Facebook.

<<<<<<< HEAD
 @return The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                                   withReadPermissions:(nullable NSArray<NSString *> *)permissions;

/**
 *Asynchronously* links Facebook with read permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
 @returns The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask *)linkUserInBackground:(PFUser *)user withReadPermissions:(PF_NULLABLE NSArray *)permissions;

/*!
 @abstract *Asynchronously* links Facebook with read permissions to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of read permissions to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(PFUser *)user
<<<<<<< HEAD
         withReadPermissions:(nullable NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block;

/**
 *Asynchronously* links Facebook with publish permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
         withReadPermissions:(PF_NULLABLE NSArray *)permissions
                       block:(PF_NULLABLE PFBooleanResultBlock)block;

/*!
 @abstract *Asynchronously* links Facebook with publish permissions to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of publish permissions to use.

<<<<<<< HEAD
 @return The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user
                                withPublishPermissions:(NSArray<NSString *> *)permissions;

/**
 *Asynchronously* links Facebook with publish permissions to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
 @returns The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask *)linkUserInBackground:(PFUser *)user withPublishPermissions:(NSArray *)permissions;

/*!
 @abstract *Asynchronously* links Facebook with publish permissions to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param permissions Array of publish permissions to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(PFUser *)user
<<<<<<< HEAD
      withPublishPermissions:(NSArray<NSString *> *)permissions
                       block:(nullable PFBooleanResultBlock)block;

/**
 *Asynchronously* links Facebook Access Token to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
      withPublishPermissions:(NSArray *)permissions
                       block:(PF_NULLABLE PFBooleanResultBlock)block;

/*!
 @abstract *Asynchronously* links Facebook Access Token to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param accessToken An instance of `FBSDKAccessToken` to use.

<<<<<<< HEAD
 @return The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask<NSNumber *> *)linkUserInBackground:(PFUser *)user withAccessToken:(FBSDKAccessToken *)accessToken;

/**
 *Asynchronously* links Facebook Access Token to an existing `PFUser`.

 This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the `PFUser`.
=======
 @returns The task that will have a `result` set to `@YES` if operation succeeds.
 */
+ (BFTask *)linkUserInBackground:(PFUser *)user withAccessToken:(FBSDKAccessToken *)accessToken;

/*!
 @abstract *Asynchronously* links Facebook Access Token to an existing <PFUser>.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 It will also save any unsaved changes that were made to the `user`.

 @param user        User to link to Facebook.
 @param accessToken An instance of `FBSDKAccessToken` to use.
 @param block       The block to execute when the linking completes.
 It should have the following signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)linkUserInBackground:(PFUser *)user
             withAccessToken:(FBSDKAccessToken *)accessToken
<<<<<<< HEAD
                       block:(nullable PFBooleanResultBlock)block;
=======
                       block:(PF_NULLABLE PFBooleanResultBlock)block;
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

///--------------------------------------
/// @name Unlinking Users
///--------------------------------------

<<<<<<< HEAD
/**
 Unlinks the `PFUser` from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @return The task, that encapsulates the work being done.
 */
+ (BFTask<NSNumber *> *)unlinkUserInBackground:(PFUser *)user;

/**
 Unlinks the `PFUser` from a Facebook account *asynchronously*.
=======
/*!
 @abstract Unlinks the <PFUser> from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)unlinkUserInBackground:(PFUser *)user;

/*!
 @abstract Unlinks the <PFUser> from a Facebook account *asynchronously*.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

 @param user User to unlink from Facebook.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
<<<<<<< HEAD
+ (void)unlinkUserInBackground:(PFUser *)user block:(nullable PFBooleanResultBlock)block;
=======
+ (void)unlinkUserInBackground:(PFUser *)user block:(PF_NULLABLE PFBooleanResultBlock)block;
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944

///--------------------------------------
/// @name Getting Linked State
///--------------------------------------

<<<<<<< HEAD
/**
 Whether the user has their account linked to Facebook.

 @param user User to check for a facebook link. The user must be logged in on this device.

 @return `YES` if the user has their account linked to Facebook, otherwise `NO`.
=======
/*!
 @abstract Whether the user has their account linked to Facebook.

 @param user User to check for a facebook link. The user must be logged in on this device.

 @returns `YES` if the user has their account linked to Facebook, otherwise `NO`.
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

@end

<<<<<<< HEAD
NS_ASSUME_NONNULL_END
=======
PF_ASSUME_NONNULL_END
>>>>>>> 2a3cbcc766224b91151fa0aada91788572b24944
