///:
/*****************************************************************************
 **                                                                         **
 **                               .======.                                  **
 **                               | INRI |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                      .========'      '========.                         **
 **                      |   _      xxxx      _   |                         **
 **                      |  /_;-.__ / _\  _.-;_\  |                         **
 **                      |     `-._`'`_/'`.-'     |                         **
 **                      '========.`\   /`========'                         **
 **                               | |  / |                                  **
 **                               |/-.(  |                                  **
 **                               |\_._\ |                                  **
 **                               | \ \`;|                                  **
 **                               |  > |/|                                  **
 **                               | / // |                                  **
 **                               | |//  |                                  **
 **                               | \(\  |                                  **
 **                               |  ``  |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                               |      |                                  **
 **                   \\    _  _\\| \//  |//_   _ \// _                     **
 **                  ^ `^`^ ^`` `^ ^` ``^^`  `^^` `^ `^                     **
 **                                                                         **
 **                       Copyright (c) 2014 Tong G.                        **
 **                          ALL RIGHTS RESERVED.                           **
 **                                                                         **
 ****************************************************************************/

#import <Cocoa/Cocoa.h>

@class SFAuthorizationView;

/** This class demonstrates AppleDoc.
 
 A second paragraph comes after an empty line.
 
	int i=0;
	i++;
 
 And some sample code can also be in a block, but indented with a TAB.
 */
@interface KCLMainWindowController : NSWindowController

@property ( nonatomic, unsafe_unretained ) IBOutlet NSSegmentedControl* keychainItemsSeg;
@property ( nonatomic, unsafe_unretained ) IBOutlet NSSegmentedControl* certificatedItemSeg;

@property ( nonatomic, unsafe_unretained ) IBOutlet NSButton* evaludateTrustButton;
@property ( nonatomic, unsafe_unretained ) IBOutlet NSButton* createCertificateButton;

@property ( nonatomic, unsafe_unretained ) IBOutlet SFAuthorizationView* authorizationView;
@property ( nonatomic, unsafe_unretained ) IBOutlet NSProgressIndicator* circleProgressIndicator;

/** This is the second super-awesome method.
 
 Note that there are additional cool things here, like [direct hyperlinks](http://www.cocoanetics.com)
 
 @param _GenericPassword Generic Password
 @param _ServiceName Service Name
 @param _UserName User Name
 @param _Keychain Keychain
 @param _KeychainItemRef Reference to Keychain Item
 @return OSStatus 
 @warning *Warning:* A blue background.
 @bug *Bug:* A yellow background.
 */
- ( OSStatus ) addGenericPassword: ( NSString* )_GenericPassword
                   withSeviceName: ( NSString* )_ServiceName
                         userName: ( NSString* )_UserName
                       toKeychain: ( SecKeychainRef )_Keychain
                     returnedItem: ( SecKeychainItemRef* )_KeychainItemRef;

+ ( instancetype ) mainWindowController;

@end // KCLMainWindowController

//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
 **                                                                         **
 **      _________                                      _______             **
 **     |___   ___|                                   / ______ \            **
 **         | |     _______   _______   _______      | /      |_|           **
 **         | |    ||     || ||     || ||     ||     | |    _ __            **
 **         | |    ||     || ||     || ||     ||     | |   |__  \           **
 **         | |    ||     || ||     || ||     ||     | \_ _ __| |  _        **
 **         |_|    ||_____|| ||     || ||_____||      \________/  |_|       **
 **                                           ||                            **
 **                                    ||_____||                            **
 **                                                                         **
 ****************************************************************************/
///:~