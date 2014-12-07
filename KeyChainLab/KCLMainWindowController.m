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

#import "KCLMainWindowController.h"

#define printErr( _ResultCode )                                                 \
    NSLog( @"Error Occured (%d): `%@' (Line: %d Function/Method: %s)"           \
         , _ResultCode                                                          \
         , ( __bridge NSString* )SecCopyErrorMessageString( resultCode, NULL )  \
         , __LINE__                                                             \
         , __func__                                                             \
         )

NSString const* kClickToLockDescription = @"Click to lock the login keychain";
NSString const* kClickToUnlockDescription = @"Click to unlock the login keychain";

// KCLMainWindowController class
@implementation KCLMainWindowController

@synthesize serviceNameTextField;
@synthesize userNameTextField;
@synthesize passwordSecureTextField;
@synthesize verifySecureTextField;

@synthesize cancleButton;
@synthesize doneButton;

@synthesize lockOrUnlockAll;
    @synthesize lockIcon;
    @synthesize unlockIcon;

#pragma mark Initializers
+ ( instancetype ) mainWindowController
    {
    return [ [ [ [ self class ] alloc ] init ] autorelease ];
    }

- ( instancetype ) init
    {
    if ( self = [ super initWithWindowNibName: @"KCLMainWindow" ] )
        {
        // TODO:
        }

    return self;
    }

OSStatus keychainCallback( SecKeychainEvent _Event
                         , SecKeychainCallbackInfo* _Info
                         , void* context
                         )
    {
    NSLog( @"Version: %u", _Info->version );
    NSLog( @"Keychain Item: %@", ( __bridge NSString* )CFCopyDescription( _Info->item ) );
    NSLog( @"Keychain: %@", ( __bridge NSString* )CFCopyDescription( _Info->keychain ) );
    NSLog( @"Process ID: %d", _Info->pid );

    return errSecSuccess;
    }

- ( void ) testingForSecItemDelete
    {
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef defaultKeychain = NULL;
    SecKeychainCopyDefault( &defaultKeychain );

    CFDictionaryRef query = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass         : ( __bridge id )kSecClassInternetPassword
         , ( __bridge id )kSecAttrLabel     : @"www.fuckfuckgo.org"
         , ( __bridge id )kSecMatchLimit    : ( __bridge id )kSecMatchLimitAll
         , ( __bridge id )kSecReturnRef     : ( __bridge id )kCFBooleanTrue
         , ( __bridge id )kSecMatchSearchList : @[ ( __bridge id )defaultKeychain ]
         };

    if ( ( resultCode = SecItemDelete( query ) ) != errSecSuccess )
        printErr( resultCode );
    }

- ( void ) testingForSecItemUpdate
    {
    OSStatus resultCode = errSecSuccess;

    CFDictionaryRef query = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass         : ( __bridge id )kSecClassInternetPassword
         , ( __bridge id )kSecAttrServer    : @"www.fuckfuckgo.org"
         , ( __bridge id )kSecMatchLimit    : ( __bridge id )kSecMatchLimitAll
         };

    CFDictionaryRef attributesToUpdate = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecAttrLabel : @"FuckFuckGo" };

    if ( ( resultCode = SecItemUpdate( query, attributesToUpdate ) ) != errSecSuccess )
        printErr( resultCode );
    }

- ( void ) testingForSecItemAdd
    {
    SecKeychainSetUserInteractionAllowed( NO );
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef NSTongG_Keychain = NULL;

    CFArrayRef cfSearchList = NULL;
    resultCode = SecKeychainCopySearchList( &cfSearchList );
    if ( resultCode == errSecSuccess && cfSearchList )
        {
        NSArray* searchList = ( __bridge NSArray* )cfSearchList;

        UInt32 pathLength = MAXPATHLEN;
        char c_path[ MAXPATHLEN + 1 ] = { 0 };
        for ( id _Elem in searchList )
            {
            resultCode = SecKeychainGetPath( ( __bridge SecKeychainRef )_Elem, &pathLength, c_path );

            if ( resultCode != errSecSuccess )
                {
                printErr( resultCode );
                return;
                }

            NSString* path = [ [ [ NSString alloc ] initWithCString: c_path
                                                           encoding: NSUTF8StringEncoding ] autorelease ];

            NSString* keychainName = [ [ path lastPathComponent ] stringByDeletingPathExtension ];
            if ( [ keychainName isEqualToString: @"NSTongG" ] )
                {
                NSTongG_Keychain = ( __bridge SecKeychainRef )_Elem;
                break;
                }

            bzero( c_path, pathLength + 1 );
            }
        }
    else
        {
        printErr( resultCode );
        return;
        }

    CFDictionaryRef attrDict = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass             : ( __bridge id )kSecClassInternetPassword
         , ( __bridge id )kSecUseKeychain       : ( __bridge id )NSTongG_Keychain
         , ( __bridge id )kSecAttrLabel         : @"Vnet HTTPS Proxy"
         , ( __bridge id )kSecAttrDescription   : @"Vnet Proxy Password"
         , ( __bridge id )kSecAttrComment       : @"I'm Tong Guo, I'm a individual OS X developer"
         , ( __bridge id )kSecAttrServer        : @"node-los.vnet.link"
         , ( __bridge id )kSecAttrAccount       : @"sosueme"
         , ( __bridge id )kSecAttrProtocol      : ( __bridge id )kSecAttrProtocolHTTPSProxy
         , ( __bridge id )kSecAttrPort          : @111

         , ( __bridge id )kSecReturnRef             : ( __bridge id )kCFBooleanTrue
//         , ( __bridge id )kSecReturnPersistentRef   : ( __bridge id )kCFBooleanTrue
//         , ( __bridge id )kSecReturnData            : ( __bridge id )kCFBooleanTrue
         };

    CFTypeRef addedItems = NULL;
    resultCode = SecItemAdd( attrDict, &addedItems );

    if ( resultCode == errSecSuccess && addedItems )
        {
        NSLog( @"%@", ( __bridge id )addedItems );

        CFTypeID typeID = CFGetTypeID( addedItems );
        if ( typeID == CFDataGetTypeID() )
            {
            NSURL* URL = [ NSURL URLWithString: @"file:///Users/EsquireTongG/addedItem.dat" ];
            if ( [ [ NSFileManager defaultManager ] fileExistsAtPath: [ URL path ] ] )
                {
                BOOL isSuccess = [ ( __bridge NSData* )addedItems writeToURL: URL atomically: YES ];
                NSLog( @"%d", isSuccess );
                }
            }
        }
    else
        printErr( resultCode );
    }

- ( void ) testingForSecItemCopyMatching
    {
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef oldDefaultKeychain = NULL;
    SecKeychainCopyDefault( &oldDefaultKeychain );

    UInt32 pathLength = MAXPATHLEN;
    char pathForDefaultKeychain[ MAXPATHLEN + 1 ];
    SecKeychainGetPath( oldDefaultKeychain, &pathLength, pathForDefaultKeychain );
    NSLog( @"%s", pathForDefaultKeychain );

    SecKeychainRef NSTongG_Keychain = NULL;
    resultCode = SecKeychainOpen( "/Users/EsquireTongG/NSTongG.keychain", &NSTongG_Keychain );
    if ( resultCode != errSecSuccess )
        return;

    resultCode = SecKeychainSetDefault( NSTongG_Keychain );
    if ( resultCode != errSecSuccess )
        NSLog( @"Failed to reset the default keychain: (%d): %@", resultCode, ( __bridge NSString* )SecCopyErrorMessageString( resultCode, NULL ) );

    SecKeychainRef defaultKeychain = NULL;
    SecKeychainCopyDefault( &defaultKeychain );

//    CFArrayRef searchList = ( __bridge CFArrayRef )
//        @[ ( __bridge id )NSTongG_Keychain, ( __bridge id )defaultKeychain ];

    CFTypeRef result = NULL;
    CFDictionaryRef queryCertificate = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass                         : ( __bridge id )kSecClassCertificate
         , ( __bridge id )kSecMatchLimit                    : ( __bridge id )kSecMatchLimitAll
//         , ( __bridge id )kSecMatchSearchList               : ( __bridge NSArray* )searchList
         , ( __bridge id )kSecMatchSubjectContains          : ( __bridge NSString* )CFSTR( "Tông GUO" )
         , ( __bridge id )kSecMatchCaseInsensitive          : ( __bridge id )kCFBooleanTrue
         , ( __bridge id )kSecMatchDiacriticInsensitive     : ( __bridge id )kCFBooleanTrue
         , ( __bridge id )kSecMatchTrustedOnly              : ( __bridge id )kCFBooleanTrue
         , ( __bridge id )kSecMatchValidOnDate              : ( __bridge NSNull* )kCFNull

         , ( __bridge id )kSecReturnAttributes              : ( __bridge id )kCFBooleanTrue
         , ( __bridge id )kSecReturnRef                     : ( __bridge id )kCFBooleanTrue
         };

    if ( ( resultCode = SecItemCopyMatching( queryCertificate, &result ) ) == errSecSuccess )
        {
        if ( CFGetTypeID( result ) == SecKeychainItemGetTypeID() )
            NSLog( @"Keychain Item Reference: %@", ( __bridge NSString* )CFCopyDescription( result ) );

        else if ( CFGetTypeID( result ) == CFDataGetTypeID() )
            {
            UInt8* bytes = malloc( ( size_t )( CFDataGetLength( result ) * sizeof( char ) ) );
            CFDataGetBytes( result, CFRangeMake( 0, CFDataGetLength( result ) ), bytes );

            bytes[ CFDataGetLength( result ) ] = '\0';

            NSLog( @"Data: %s", bytes );
            free( bytes );
            }

        else if ( CFGetTypeID( result ) == CFDictionaryGetTypeID() )
            NSLog( @"Attr Dict: %@", ( __bridge NSDictionary* )result );

        else if ( CFGetTypeID( result ) == CFArrayGetTypeID() )
            {
            NSLog( @"Refs: %@", ( __bridge NSArray* )result );
        #if 0
            CFArrayRef itemList = ( __bridge CFArrayRef )
                @[ ( __bridge id )( CFArrayGetValueAtIndex( result, 0 ) ) ];

            CFDictionaryRef queryFuck = ( __bridge CFDictionaryRef )
                @{ ( __bridge id )kSecMatchItemList     : ( __bridge id )itemList
                 , ( __bridge id )kSecReturnAttributes  : ( __bridge id )kCFBooleanTrue
                 , ( __bridge id )kSecMatchLimit        : ( __bridge id )kSecMatchLimitAll
                 };

            CFTypeRef resultsFuck = NULL;
            resultCode = SecItemCopyMatching( queryFuck, &resultsFuck );
                printErr( resultCode );

            NSLog( @"%@", ( __bridge NSArray* )resultsFuck );
        #endif
            }
        }
    else
        printErr( resultCode );
    }

#pragma mark Conforms <NSNibAwaking> protocol
- ( void ) awakeFromNib
    {
//    [ self testingForSecItemCopyMatching ];
    [ self testingForSecItemAdd ];

#if 0
    SecKeychainAddCallback( keychainCallback, kSecEveryEventMask, NULL );

    self.lockIcon = [ NSImage imageNamed: NSImageNameLockLockedTemplate ];;
    self.unlockIcon = [ NSImage imageNamed: NSImageNameLockUnlockedTemplate ];;

//    OSStatus resultCode = errSecSuccess;

    SecKeychainStatus keychainStatus = 0;
    SecKeychainGetStatus( NULL, &keychainStatus );

    if ( keychainStatus & kSecUnlockStateStatus )
        [ self.lockOrUnlockAll setImage: unlockIcon ];
    else
        [ self.lockOrUnlockAll setImage: lockIcon ];
#endif
//    CFArrayRef searchList = NULL;
//    if ( ( resultCode = SecKeychainCopySearchList( &searchList ) ) == errSecSuccess )
//        {
//        SecKeychainStatus keychainStatus = 0;
//        BOOL allIsLocked = YES;
//        for ( int index = 0; index < CFArrayGetCount( searchList ); index++ )
//            {
//            SecKeychainGetStatus( ( SecKeychainRef )CFArrayGetValueAtIndex( searchList, index ), &keychainStatus);
//
//            if ( ( keychainStatus & kSecUnlockStateStatus ) == 0 )
//                {
//                allIsLocked = NO;
//                break;
//                }
//            }
//
//        if ( allIsLocked )
//            icon = [ NSImage imageNamed: NSImageNameLockLockedTemplate ];
//        else
//            icon = [ NSImage imageNamed: NSImageNameLockUnlockedTemplate ];
//        }

//    NSImage* unlock = [ NSImage imageNamed: NSImageNameLockLockedTemplate ];

//    SecKeychainSetUserInteractionAllowed( NO );

#if 0
    SecProtocolType protocolType = kSecProtocolTypeHTTPSProxy;
    SecKeychainAttribute attrs[] =
        { { kSecProtocolItemAttr, ( UInt32 )sizeof( SecProtocolType) , ( void* )&protocolType } };

    SecKeychainAttributeList attrsList = { sizeof( attrs ) / sizeof( attrs[ 0 ] ), attrs };
    SecKeychainSearchRef search = NULL;
    if ( ( resultCode = SecKeychainSearchCreateFromAttributes( NULL, kSecInternetPasswordItemClass, &attrsList, &search ) ) == errSecSuccess
            && search )
        {
        SecKeychainItemRef item = NULL;
        while ( ( resultCode = SecKeychainSearchCopyNext( search, &item ) ) != errSecItemNotFound )
            {
//            NSLog( @"I found it! %@", ( __bridge NSString* )CFCopyDescription( item ) );

            SecKeychainAttributeList* attributeList = NULL;
            SecItemClass itemClass = CSSM_DL_DB_RECORD_ALL_KEYS;
            UInt32 passwordLength = 0;
            char const* password = NULL;

            SecKeychainAttributeInfo* attributeInfo = NULL;
            resultCode = SecKeychainAttributeInfoForItemID( NULL, CSSM_DL_DB_RECORD_INTERNET_PASSWORD, &attributeInfo );
            if ( resultCode != errSecSuccess )
                printErr( resultCode );

            resultCode = SecKeychainItemCopyAttributesAndData( item, attributeInfo, &itemClass, &attributeList, &passwordLength, (void* )&password );
            if ( resultCode == errSecSuccess )
                {
                printf( "\n\n\n" );
                NSLog( @"Item Class: %c", itemClass );
                NSLog( @"Password: %s", password );
                NSLog( @"Password Length: %u", passwordLength );

//                NSLog( @"%@", ( __bridge NSString* )CFCopyDescription( attributeList ) );
                SecKeychainAttribute* attrs = attributeList->attr;
                for ( int index = 0; index < attributeList->count; index++ )
                    {
//                    NSLog( @"Type: %d", attrs[ 0 ].tag );
                    printf( "%s\n", attrs[ index ].data );
                    }

                printf( "\n\n\n" );
                }
            else
                printErr( resultCode );
            }
        }
    else
        printErr( resultCode );
#endif

#if 0
//    resultCode = SecKeychainSetUserInteractionAllowed( NO );
    NSLog( @"Error Code %u: %@", resultCode, SecCopyErrorMessageString( resultCode, NULL ) );
    SecKeychainRef newKeychain = NULL;
    char const* keychainPath = "/Users/EsquireTongG/Desktop/NSTongG.keychain";
    char const* passwordForNewKeyChain = "isgtforever";
    if ( ( resultCode = SecKeychainCreate( keychainPath
                                         , ( UInt32 )strlen( passwordForNewKeyChain ), passwordForNewKeyChain
                                         , FALSE
                                         , NULL
                                         , &newKeychain
                                         ) ) != errSecSuccess )
        {
        NSLog( @"#2 Error Code %u: %@", resultCode, SecCopyErrorMessageString( resultCode, NULL ) );
        }

//    SecKeychainUnlockAll();

    UInt32 version = 0;
    SecKeychainGetVersion( &version );
    NSLog( @"Current Version: %u", version );
    SecKeychainSettings keychainSettings = { version, YES, YES, 32 };
    if ( ( resultCode = SecKeychainSetSettings( newKeychain, &keychainSettings ) ) != errSecSuccess )
        printErr( resultCode );

    void* label = "Vnet Link (sosueme)";
    void* server = "node-cnx.vnet.link";
    void* account = "sosueme";
    void* comment = "Big Brother Is WATCHING You!";
    void* description = "Proxy Password";
    BOOL isInvisible = NO;
    UInt32 creator = 'Tong';
    SecProtocolType protocol = kSecProtocolTypeHTTPSProxy;
    short port = 110;
    SecKeychainAttribute attrs[] = { { kSecLabelItemAttr, ( UInt32 )strlen( label ), label }
                                   , { kSecServerItemAttr, ( UInt32 )strlen( server ), server }
                                   , { kSecAccountItemAttr, ( UInt32 )strlen( account ), account }
                                   , { kSecProtocolItemAttr, sizeof( SecProtocolType ), ( SecProtocolType* )&protocol }
                                   , { kSecPortItemAttr, sizeof( short ), ( short* )&port }
                                   , { kSecCommentItemAttr, ( UInt32 )strlen( comment ), comment }
                                   , { kSecDescriptionItemAttr, ( UInt32 )strlen( description ), description }
                                   , { kSecCreatorItemAttr, sizeof( UInt32 ), &creator }
                                   , { kSecInvisibleItemAttr, sizeof( BOOL ), ( void* )&isInvisible }
                                   };

    SecKeychainAttributeList attrsList = { sizeof( attrs ) / sizeof( attrs[ 0 ] ), attrs };

    SecAccessRef access = createAccess( @"Let there be light" );
    SecKeychainItemRef newItem = [ self addKeychainItemOfClass: kSecInternetPasswordItemClass
                                                    toKeychain: newKeychain
                                                  withPassword: @"dontebabitch77!."
                                                attributesList: &attrsList
                                      initialAccessControlList: access
                                                        status: &resultCode ];

    CFTypeRef authTag = kSecACLAuthorizationDecrypt;
    CFArrayRef ACLList = SecAccessCopyMatchingACLList( access, authTag );
    NSLog( @"%@", ( __bridge NSArray* )ACLList );
    if ( resultCode == errSecSuccess )
        NSLog( @"%@", ( __bridge NSString* )CFCopyDescription( newItem ) );
    else
        printErr( resultCode );
#endif
    }

#pragma mark IBActions
- ( IBAction ) lockAllKeychain: ( id )_Sender
    {
    SecKeychainLockAll();
    }

- ( IBAction ) escape: ( id )_Sender
    {
    [ self testingForSecItemDelete ];
    }

- ( IBAction ) allIsDone: ( id )_Sender
    {
//    SecKeychainLockAll();
//    SecKeychainRemoveCallback( keychainCallback );

    [ self testingForSecItemUpdate ];
    }

- ( SecKeychainItemRef ) addKeychainItemOfClass: ( SecItemClass )_ItemClass
                                     toKeychain: ( SecKeychainRef )_Keychain
                                   withPassword: ( NSString* )_Password
                                 attributesList: ( SecKeychainAttributeList* )_AttrList
                       initialAccessControlList: ( SecAccessRef )_InitialAccess
                                         status: ( OSStatus* )_Status
    {
    SecKeychainItemRef newItem = NULL;
    OSStatus resultCode = errSecSuccess;

    const void* password = ( const void* )[ _Password UTF8String ];
    resultCode = SecKeychainItemCreateFromContent( _ItemClass
                                                 , _AttrList
                                                 ,( UInt32 )strlen( password )
                                                 , password
                                                 , _Keychain
                                                 , _InitialAccess
                                                 , &newItem
                                                 );
    if ( _Status )
        *_Status = resultCode;

    return newItem;
    }

- ( OSStatus ) addGenericPassword: ( NSString* )_GenericPassword
                   withSeviceName: ( NSString* )_ServiceName
                         userName: ( NSString* )_UserName
                       toKeychain: ( SecKeychainRef )_Keychain
                     returnedItem: ( SecKeychainItemRef* )_KeychainItemRef
    {
    char const* password = [ _GenericPassword UTF8String ];
    char const* serviceName = [ _ServiceName UTF8String ];
    char const* userName = [ _ServiceName UTF8String ];

    OSStatus resultCode = SecKeychainAddGenericPassword( _Keychain
                                                       , ( UInt32 )strlen( serviceName ), serviceName
                                                       , ( UInt32 )strlen( userName ), userName
                                                       , ( UInt32 )strlen( password ), password
                                                       , _KeychainItemRef
                                                       );
    return resultCode;
    }

SecAccessRef createAccess( NSString* _AccessLabel )
    {
    OSStatus resultCode = errSecSuccess;

    SecAccessRef access = nil;

    SecTrustedApplicationRef me = NULL;
    SecTrustedApplicationRef OhMyCal = NULL;
    SecTrustedApplicationRef SourceTree = NULL;

    resultCode = SecTrustedApplicationCreateFromPath( NULL, &me );
    resultCode = resultCode ?: SecTrustedApplicationCreateFromPath( "/Applications/Oh My Cal!.app",  &OhMyCal );
    resultCode = resultCode ?: SecTrustedApplicationCreateFromPath( "/Applications/SourceTree.app",  &SourceTree );

    if ( resultCode == errSecSuccess )
        {
        NSArray* trustedApplications = @[ ( id )me, ( id )OhMyCal, ( id )SourceTree ];

        SecAccessCreate( ( CFStringRef )_AccessLabel
                       , ( __bridge CFArrayRef )trustedApplications
                       , &access
                       );
        }

    return access;
    }

#pragma mark -
- ( SecAccessRef ) createAccess: ( NSString* )_AccessLabel
    {
    OSStatus err;
    SecAccessRef access = NULL;
    NSArray* trustedApplications = NULL;

    /* Make an application list of trusted applications;
     * that is, applications that are allowed to access the item without
     * requiring user confirmation */
    SecTrustedApplicationRef myself = NULL;
    SecTrustedApplicationRef someOther = NULL;

    /* Create trusted application references;
     * see SecTrustedApplications.h: */
    err = SecTrustedApplicationCreateFromPath( NULL, &myself );
    err = err ?: SecTrustedApplicationCreateFromPath( "/Applications/SourceTree.app", &someOther );

    if ( err == errSecSuccess )
        trustedApplications = @[ ( id )myself, ( id )someOther ];

    /* Create a access object */
    err = err ?: SecAccessCreate( ( __bridge CFStringRef )_AccessLabel
                                , ( __bridge CFArrayRef )trustedApplications
                                , &access
                                );
    if ( err )
        return nil;

    return access;
    }
#if 0
- ( OSStatus ) addInternetPassword: ( NSString* )_Password
                           account: ( NSString* )_Account
                            server: ( NSString* )_Server
                         itemLabel: ( NSString* )_ItemLabel
                              path: ( NSString* )_Path
                          protocol: ( SecProtocolType )_Protocol
                              port: ( short )_Port
    {
    OSStatus err;
    SecKeychainItemRef item = NULL;
    char const* pathUTF8 = [ _Path UTF8String ];
    char const* serverUTF8 = [ _Server UTF8String ];
    char const* accountUTF8 = [ _Account UTF8String ];
    char const* passwordUTF8 = [ _Password UTF8String ];
    char const* itemLabelUTF8 = [ _ItemLabel UTF8String ];

    // Create initial access control settings for the item:
    SecAccessRef access = createAccess( _ItemLabel );

    // Following is the lower-level equivalent to the SecKeychainAddInternetPassword function:
    NSAssert( strlen( itemLabelUTF8 ) <= 0xFFFFFFFF, nil );
    NSAssert( strlen( accountUTF8 ) <= 0xFFFFFFFF, nil );
    NSAssert( strlen( serverUTF8 ) <= 0xFFFFFFFF, nil );
    NSAssert( strlen( pathUTF8 ) <= 0xFFFFFFFF, nil );

    // Set up the attribute vector (each attribute consits of {tag, length, pointer} ):
    SecKeychainAttribute attrs[] =
        { { kSecLabelItemAttr, ( UInt32 )strlen( itemLabelUTF8 ), ( char* )itemLabelUTF8 }
        , { kSecAccountItemAttr, ( UInt32 )strlen( accountUTF8 ), ( char* )accountUTF8 }
        , { kSecServerItemAttr, ( UInt32 )strlen( serverUTF8 ), ( char* )serverUTF8 }
        , { kSecPathItemAttr, ( UInt32 )strlen( pathUTF8 ), ( char* )pathUTF8 }
        , { kSecPortItemAttr, sizeof( short ), ( short* )&port }
        };
    }
#endif
@end // KCLMainWindowController

//////////////////////////////////////////////////////////////////////////////

/*****************************************************************************
 **                                                                         **
 **                                                                         **
 **      █████▒█    ██  ▄████▄   ██ ▄█▀       ██████╗ ██╗   ██╗ ██████╗     **
 **    ▓██   ▒ ██  ▓██▒▒██▀ ▀█   ██▄█▒        ██╔══██╗██║   ██║██╔════╝     **
 **    ▒████ ░▓██  ▒██░▒▓█    ▄ ▓███▄░        ██████╔╝██║   ██║██║  ███╗    **
 **    ░▓█▒  ░▓▓█  ░██░▒▓▓▄ ▄██▒▓██ █▄        ██╔══██╗██║   ██║██║   ██║    **
 **    ░▒█░   ▒▒█████▓ ▒ ▓███▀ ░▒██▒ █▄       ██████╔╝╚██████╔╝╚██████╔╝    **
 **     ▒ ░   ░▒▓▒ ▒ ▒ ░ ░▒ ▒  ░▒ ▒▒ ▓▒       ╚═════╝  ╚═════╝  ╚═════╝     **
 **     ░     ░░▒░ ░ ░   ░  ▒   ░ ░▒ ▒░                                     **
 **     ░ ░    ░░░ ░ ░ ░        ░ ░░ ░                                      **
 **              ░     ░ ░      ░  ░                                        **
 **                    ░                                                    **
 **                                                                         **
 ****************************************************************************/