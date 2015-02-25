
#import <Foundation/Foundation.h>

#ifndef LOG_CONTEXT_ALL
#define LOG_CONTEXT_ALL             INT_MAX
#endif

#ifndef LOG_CONTEXT_UNSPECIFIED
#define LOG_CONTEXT_UNSPECIFIED     (1 << 0)
#endif

#ifndef LOG_CONTEXT_SERVER
#define LOG_CONTEXT_SERVER          (1 << 1)
#endif

#ifndef LOG_CONTEXT_CONNECTION
#define LOG_CONTEXT_CONNECTION      (1 << 2)
#endif

#ifndef LOG_CONTEXT_LOCAL
#define LOG_CONTEXT_LOCAL           (1 << 3)
#endif

#ifndef LOG_CONTEXT_COMMUNICATION
#define LOG_CONTEXT_COMMUNICATION   (1 << 4)
#endif

#ifndef LOG_FLAG_ERROR
#define LOG_FLAG_ERROR    (1 << 0)  // 0...00001
#endif

#ifndef LOG_FLAG_WARN
#define LOG_FLAG_WARN     (1 << 1)  // 0...00010
#endif

#ifndef LOG_FLAG_INFO
#define LOG_FLAG_INFO     (1 << 2)  // 0...00100
#endif

#ifndef LOG_FLAG_DEBUG
#define LOG_FLAG_DEBUG    (1 << 3)  // 0...01000
#endif

#ifndef LOG_FLAG_VERBOSE
#define LOG_FLAG_VERBOSE  (1 << 4)  // 0...10000
#endif


@class Outbox;

typedef void (^Inbox) (NSMutableDictionary *payload, NSMutableDictionary *options, Outbox *outbox);

@interface Outbox : NSObject {
    
    NSString *to;
    NSString *from;
    NSString *your;
    NSString *origin;
}

/** Outbox
 *  @param payload payload
 *  @param options optionste
 *  @return Outbox */
- (Outbox *) init: (NSMutableDictionary *) payload : (NSMutableDictionary *) options;

/** On incoming messages you can respond directly in the inbox, this way the sender will receive your response in the inbox he/she specified in the put function
 *  @param payload The data to be sent to the recipient.
 *  @param options A dictonary of options. For possible keys and values see options reference on developer.apptimate.io.
 *  @param inbox An inbox to handle any response message to the response message. */
- (void) put: (NSDictionary *) payload withOptions: (NSDictionary*) options andInbox: (Inbox) inbox;

/** Each apptimate.io app has its own unique keys pair. This makes sure only you have access to your app. The api keys are used internally to sign all communication with the server. You can find your app keys on your Dashboard (dashboard.apptimate.io) -> Apps.
 *  @param publicKey The public key for your app.
 *  @param privateKey The private key for your app. */
+ (void) setAPIKeys: (NSString *) publicKey andPrivate: (NSString *) privateKey;

/** Each apptimate.io app has its own unique keys pair. This makes sure only you have access to your app. The api keys are used internally to sign all communication with the server. You can find your app keys on your Dashboard (dashboard.apptimate.io) -> Apps.
 *  @param publicKey The public key for your app.
 *  @param privateKey The private key for your app.
 *  @param options A NSDictionary where you can opt out of Outbox standard behaviors for "history" and "lifecycle". If set to nil the default behavior for both history and lifecycle are kept. You can read more on how to opt out from history and lifecycle on developer.apptimate.io. */
+ (void) setAPIKeys: (NSString *) publicKey andPrivate: (NSString *) privateKey andOptions: (NSDictionary *) options;

/** In short this sends a message to a specified tag and all its subscribers.
 *  @param to The tag of the receiver.
 *  @param payload The data to be sent to the recipient. */
+ (void) put: (NSString *) to withPayload: (NSDictionary *) payload;

/** In short this sends a message to a specified tag and all its subscribers.
 *  @param to The tag of the receiver.
 *  @param payload The data to be sent to the recipient.
 *  @param options A dictonary of options. For possible keys and values see options reference on developer.apptimate.io. */
+ (void) put: (NSString *) to withPayload: (NSDictionary *) payload andOptions: (NSDictionary *) options;

/** In short this sends a message to a specified tag and all its subscribers.
 *  @param to The tag of the receiver.
 *  @param payload The data to be sent to the recipient.
 *  @param options A dictonary of options. For possible keys and values see options reference on developer.apptimate.io.
 *  @param inbox An inbox to handle any response message. To learn more about this read about outbox instance put method on developer.apptimate.io. */
+ (void) put: (NSString *) to withPayload: (NSDictionary *) payload andOptions: (NSDictionary *) options andInbox: (Inbox) inbox;

/** Attaches an inbox code-block to be called when receiving a message.
 *  @param inbox The code-block that will handle received messages.
 An inbox set to nil will raise a NSException. */
+ (void) attachInbox: (Inbox) inbox;

/** Attaches an inbox code-block to be called when receiving a message that the predicate evaluates to true.
 *  @param inbox The code-block that will handle received messages.
 An inbox set to nil will raise a NSException.
 *  @param predicate Used to filters messages. Can filter on the payload (the message sent by the the recipient) and/or options (the options specified for this message by the sender). A predicate set to nil is equivalent with “TRUEPREDICATE” e.i. the inbox is always called. */
+ (void) attachInbox: (Inbox) inbox withPredicate: (NSPredicate *) predicate;

/** Detaches an inbox code-block, it will no longer be called when receiving messages. Important to note! You must use the same instance of inbox as you used in attachInbox:inbox when removing it.
 *  @param inbox A inbox to remove. An inbox set to nil will raise a NSException. */
+ (void) detachInbox: (Inbox) inbox;

/** Detaches an inbox code-block, it will no longer be called when receiving messages. Important to note! You must use the same instances of inbox and predicate as you used in attachInbox:inbox withPredicate:predicate when removing them.
 *  @param inbox A inbox to remove. An inbox set to nil will raise a NSException.
 *  @param predicate A predicate to remove. A predicate set to nil will remove all instances of the inbox no matter what predicate it was attached with. */
+ (void) detachInbox: (Inbox) inbox withPredicate: (NSPredicate *) predicate;

/** This method, in combination with resign, prevents/allows the Outbox from receiving or sending messages. However if the the device has registered for push notifications and the sender has specified push as fallback or force, messages will still be pushed to the device through apples push notification service. When resume is called, the Outbox will resume real time communication and sockets will be reconnected. */
+ (void) resume;

/** This method, in combination with resume, allows/prevents the Outbox from receiving or sending messages. However if the the device has registered for push notifications and the sender has specified push as fallback or force, messages will still be pushed to the device through apples push notification service. When resign is called, the Outbox will stop the real time communication and sockets will be disconnected. */
+ (void) resign;

/** hashIfTag
 *  @param tag tag
 *  @return NSString */
+ (NSString *) hashIfTag: (NSString *) tag;

/** Sets up the connection and starts receiving messages directed to the deviceTag through recursive subscription or directly.
 *  @param deviceTag The deviceTag is a unique tag to identify the device on the server. To create a unique tag use the [Outbox createUniqueTag] function. This tag should always be in the bottom of the subscription hierarchy. */
+ (void) startWithTag: (NSString *) deviceTag;

/** Sets up the connection and starts receiving messages directed to the deviceTag through recursive subscription or directly.
 *  @param deviceTag The deviceTag is a unique tag to identify the device on the server. To create a unique tag use the [Outbox createUniqueTag] function. This tag should always be in the bottom of the subscription hierarchy.
 *  @param callback A code-block to be called on completion, if the call was successful the error parameter will be set to nil. */
+ (void) startWithTag: (NSString *) deviceTag andCallback: (void(^)(NSError *error)) callback;

/** Sets up the connection and starts receiving messages directed to the deviceTag through recursive subscription or directly.
 *  @param deviceTag The deviceTag is a unique tag to identify the device on the server. To create a unique tag use the [Outbox createUniqueTag] function. This tag should always be in the bottom of the subscription hierarchy. If the aliasTag isn’t nil the deviceTag is set to subscribe on the aliasTag.
 *  @param aliasTag To be used on the “from” key in options. */
+ (void) startWithTag: (NSString *) deviceTag andAlias: (NSString *) aliasTag;

/** Sets up the connection and starts receiving messages directed to the deviceTag through recursive subscription or directly.
 *  @param deviceTag The deviceTag is a unique tag to identify the device on the server. To create a unique tag use the [Outbox createUniqueTag] function. This tag should always be in the bottom of the subscription hierarchy. If the aliasTag isn’t nil the deviceTag is set to subscribe on the aliasTag.
 *  @param aliasTag To be used on the “from” key in options.
 *  @param callback A code-block to be called on completion, if the call was successful the error parameter will be set to nil. */
+ (void) startWithTag: (NSString *) deviceTag andAlias: (NSString *) aliasTag andCallback: (void(^)(NSError * error)) callback;

/** startLifecycle */
+ (void) startLifecycle;

/** startLifecycle */
+ (void) stopLifecycle;

/** Outbox has a transaction system built in to make sure that all messages sent from the device reaches the server and the other way around. To keep track of what is sent and what is received it uses tickets. By default the latest ticket is stored in Shared Preferences but you can override this behavior by calling startHistory with your own code-block that stores the ticket. You can turn off history completely by setting the history key to NO in the setAPIKeys call.
 *  @param ticket The latest ticket received from the saveBlock, nil the very first time the app is run.
 *  @param save The code-block that stores tickets as the latest ticket each time a new one is received. */
+ (void) startHistory: (NSString *) ticket andSaveBlock: (void(^)(NSError *error, NSString *ticket)) save;

/** Stops the storeBlock from being called. see startHistory to learn more. */
+ (void) stopHistory;

/** This creates a unique tag by hashing a unix (timestamp)+(random int) with the (private key).
 *  @return NSString The created tag */
+ (NSString *) createUniqueTag;

/** Registers a tag on the server. This is useful when you have a when you want a node to send output to but you don’t want to receive incoming messages on said tag.  Important! No messages sent to this tag will be received by anyone before someone subscribes to it.
 *  @param tag The tag to be registered. */
+ (void) registerTag: (NSString *) tag;

/** Registers a tag on the server. This is useful when you have a when you want a node to send output to but you don’t want to receive incoming messages on said tag.  Important! No messages sent to this tag will be received by anyone before someone subscribes to it.
 *  @param tag The tag to be registered.
 *  @param callback A code-block that will be called on completion. On success the error will be set to nil
 if the callback is set to nil will simply not be called. This however is not recommended since there is no way of knowing if an error occurred. */
+ (void) registerTag: (NSString *) tag withCallback: (void(^)(NSError *error)) callback;

/** Unregisters a tag on the server. Subscribers will no longer receive messages sent to the tag.
 *  @param tag A tag to be unregistered. */
+ (void) unregisterTag: (NSString *) tag;

/** Unregisters a tag on the server. Subscribers will no longer receive messages sent to the tag.
 *  @param tag A tag to be unregistered.
 *  @param callback A code-block that will be called on completion. On success the error will be set to nil. If the callback is set to nil will simply not be called. This however is not recommended since there is no way of knowing if an error occurred. */
+ (void) unregisterTag: (NSString *) tag withCallback: (void(^)(NSError *error)) callback;

/** Subscribes the child tag to receive messages sent to the parent tag. If the parent tag does not exist, it will be created.
 *  @param childTag A tag to subscribe on messages.
 *  @param parentTag A tag to be subscribed on. */
+ (void) subscribeTag: (NSString *) childTag toParent: (NSString *) parentTag;

/** Subscribes the child tag to receive messages sent to the parent tag. If the parent tag does not exist, it will be created.
 *  @param childTag A tag to subscribe on messages.
 *  @param parentTag A tag to be subscribed on.
 *  @param callback A code-block that will be called on completion. On success, the error will be set to nil if the callback is set to nil will simply not be called. This however is not recommended since there is no way of knowing if an error occurred. */
+ (void) subscribeTag: (NSString *) childTag toParent: (NSString *) parentTag withCallback: (void(^)(NSError *error)) callback;

/** Unsubscribes a childTag from a parentTag so that it no longer receives messages sent to the parentTag.
 *  @param childTag A tag to be removed as subscriber.
 *  @param parentTag A tag that will loose one of its subscribers. */
+ (void) unsubscribeTag: (NSString *) childTag fromParent: (NSString *) parentTag;

/** Unsubscribes a childTag from a parentTag so that it no longer receives messages sent to the parentTag.
 *  @param childTag A tag to be removed as subscriber.
 *  @param parentTag A tag that will loose one of its subscribers.
 *  @param callback A code-block to be called on completion, if the call was successful the err parameter will be set to nil. */
+ (void) unsubscribeTag: (NSString *) childTag fromParent: (NSString *) parentTag withCallback: (void(^)(NSError *error)) callback;

/** Fetches a tag representation for all direct and indirect subscribers of a tag. !IMPORTANT! Since Apptimates server only stores, receives and sends tags in hashed form it is impossible to get the plain text representation of a tag (“#john”). Therefore what is fetched by this method is a tag representation (“~4d1a24b376d839d2430cb7755eebdac9″) of the tags. However you can use tags and tag representations interchangeably.
 *  @param parentTag The tag to fetch all tag representations of direct and indirect subscribers
 *  @param callback A code-block that will be called on completion. error: is set to nil on success. list: is an NSArray with the tag representations of all direct and indirect subscribers. */
+ (void) resolveTag: (NSString *) parentTag withCallback: (void(^)(NSError *error, NSArray *list)) callback;

/** This method exists so that you can check if a tag is registered on the server.
 *  @param tag A tag that will be checked for existence.
 *  @param callback A code-block that will be called on completion where callback parameters: error is set to nil on success and didExist is YES if the tag exists. */
+ (void) tagExists: (NSString *) tag withCallback: (void(^)(NSError *error, BOOL exists)) callback;

/** This method exists so that you can check if a list of tags exists in the system.
 *  @param tags A list of tags that will be checked for existance.
 *  @param callback A code-block that will be called on completion callback parameters: error is set to nil on success and list is an NSArray with the tags that where registered on the server. */
+ (void) tagsExist: (NSArray *) tags withCallback: (void(^)(NSError *error, NSArray *list)) callback;

/** Registers the “Apple deviceToken” of a device to Apptimatesserver. This method should only be performed once and most likely it should be called from the appDelegates didRegisterForRemoteNotificationsWithDeviceToken:deviceToken method. A registered device receives push notifications when the sender has specified it in the messages options. Important to note is you need to register the push certificates on Apptimates server before Apptimates server can start pushing.
 *  @param tag The same tag you used when you called [Outbox startWithTag:deviceTag] or [Outbox startWithTag:deviceTag and Alias:@"#john"] If the deviceTag is set to nil will raise a NSException.
 *  @param token The deviceToken received in didRegisterForRemoteNotificationsWithDeviceToken:. If the deviceToken is set to nil will raise a NSException.
 *  @param debug A BOOL value to flag which certificate should be used when pushing to this device where: YES = “Development SSL Certificate” and NO = “Production SSL Certificate”. */
+ (void) registerForPushNotifications: (NSString *) tag withPushToken: (NSData *) token isDebug: (BOOL) debug;

/** Registers the “Apple deviceToken” of a device to Apptimatesserver. This method should only be performed once and most likely it should be called from the appDelegates didRegisterForRemoteNotificationsWithDeviceToken:deviceToken method. A registered device receives push notifications when the sender has specified it in the messages options. Important to note is you need to register the push certificates on Apptimates server before Apptimates server can start pushing.
 *  @param tag The same tag you used when you called [Outbox startWithTag:deviceTag] or [Outbox startWithTag:deviceTag and Alias:@"#john"] If the deviceTag is set to nil will raise a NSException.
 *  @param token The deviceToken received in didRegisterForRemoteNotificationsWithDeviceToken:. If the deviceToken is set to nil will raise a NSException.
 *  @param debug A BOOL value to flag which certificate should be used when pushing to this device where: YES = “Development SSL Certificate” and NO = “Production SSL Certificate”.
 *  @param callback A code-block that will be called on completion. On success, the error will be set to nil. If the callback is set to nil will simply not be called. This however is not recommended since there is no way of knowing if an error occurred. */
+ (void) registerForPushNotifications: (NSString *) tag withPushToken: (NSData *) token isDebug: (BOOL) debug andCallback: (void(^)(NSError *error)) callback;

/** stopLogging */
+ (void) stopLogging;

/** setLogLevelMask
 *  @param logLevel logLevel
 *  @param whiteListMask whiteListMask */
+ (void) setLogLevelMask: (int) logLevel  andContextMask:(int) whiteListMask;


@end