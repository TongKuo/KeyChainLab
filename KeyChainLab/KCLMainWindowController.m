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
#import <SecurityInterface/SFCertificatePanel.h>
#import <SecurityInterface/SFCertificateTrustPanel.h>
#import <SecurityInterface/SFCertificateView.h>

#define printErr( _ResultCode )                                                 \
    NSLog( @"Error Occured (%d): `%@' (Line: %d Function/Method: %s)"           \
         , _ResultCode                                                          \
         , ( __bridge NSString* )SecCopyErrorMessageString( resultCode, NULL )  \
         , __LINE__                                                             \
         , __func__                                                             \
         )

#define KCLRelease( _Object )   \
    if ( _Object )              \
        CFRelease( _Object )    \

NSString const* kClickToLockDescription = @"Click to lock the login keychain";
NSString const* kClickToUnlockDescription = @"Click to unlock the login keychain";

// KCLMainWindowController class
@implementation KCLMainWindowController

@synthesize keychainItemsSeg;
@synthesize certificatedItemSeg;

@synthesize evaludateTrustButton;
@synthesize createCertificateButton;

@synthesize authorizationView;

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
//    SecKeychainSetUserInteractionAllowed( NO );
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
            NSURL* URL = [ NSURL URLWithString: @"file:///Users/EsquireTongG/CertsForKeychainLab/addedItem.dat" ];
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

//    SecKeychainRef oldDefaultKeychain = NULL;
//    SecKeychainCopyDefault( &oldDefaultKeychain );

//    UInt32 pathLength = MAXPATHLEN;
//    char pathForDefaultKeychain[ MAXPATHLEN + 1 ];
//    SecKeychainGetPath( oldDefaultKeychain, &pathLength, pathForDefaultKeychain );
//    NSLog( @"%s", pathForDefaultKeychain );

    SecKeychainRef NSTongG_Keychain = NULL;
    resultCode = SecKeychainOpen( "/Users/EsquireTongG/CertsForKeychainLab/NSTongG.keychain", &NSTongG_Keychain );
    if ( resultCode != errSecSuccess )
        return;

//    resultCode = SecKeychainSetDefault( NSTongG_Keychain );
//    if ( resultCode != errSecSuccess )
//        printErr( resultCode );

    SecKeychainRef defaultKeychain = NULL;
    SecKeychainCopyDefault( &defaultKeychain );

//    CFArrayRef searchList = ( __bridge CFArrayRef )
//        @[ ( __bridge id )NSTongG_Keychain, ( __bridge id )defaultKeychain ];

    CFTypeRef result = NULL;
    CFDictionaryRef queryCertificate = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass                         : ( __bridge id )kSecClassCertificate
         , ( __bridge id )kSecMatchLimit                    : ( __bridge id )kSecMatchLimitAll
//         , ( __bridge id )kSecMatchSearchList               : ( __bridge NSArray* )searchList
         , ( __bridge id )kSecMatchSubjectContains          : ( __bridge NSString* )CFSTR( "Mac Developer" )
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
            NSMutableArray* certificates = [ NSMutableArray array ];
            [ ( __bridge NSArray* )result enumerateObjectsUsingBlock:
                ^( NSDictionary* _Elem, NSUInteger _Index, BOOL* _Stop )
                    {
                    [ certificates addObject: ( __bridge id )( _Elem[ @"v_Ref" ] ) ];
                #if 0
                    CFDataRef data = NULL;
                    SecKeychainItemCreatePersistentReference( ( __bridge SecKeychainItemRef )( _Elem[ @"v_Ref" ] ), &data );

                    NSError* err = nil;
                    BOOL isSuccess = [ ( __bridge NSData* )data writeToFile: @"/Users/EsquireTongG/CertsForKeychainLab/keychainItem.dat"
                                                                    options: NSDataWritingAtomic
                                                                      error: &err ];

                    if ( !isSuccess || err )
                        {
                        [ self presentError: err ];
                        *_Stop = YES;
                        }
                #endif
                    } ];

            SFCertificatePanel* certificatePanel = [ SFCertificatePanel sharedCertificatePanel ];
            [ certificatePanel setDefaultButtonTitle: NSLocalizedString( @"I see", nil ) ];
            [ certificatePanel setAlternateButtonTitle: NSLocalizedString( @"Opps!", nil ) ];
            [ certificatePanel setShowsHelp: YES ];
            [ certificatePanel runModalForCertificates: certificates showGroup: YES ];
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
    

#if 0
    NSData* persistentItem = [ NSData dataWithContentsOfFile: @"/Users/EsquireTongG/CertsForKeychainLab/keychainItem.dat" ];
    SecKeychainItemRef itemAwakedFromPersistentData = NULL;
    SecKeychainItemCopyFromPersistentReference( ( __bridge CFDataRef )persistentItem, &itemAwakedFromPersistentData );

    SFCertificatePanel* certPanel = [ SFCertificatePanel sharedCertificatePanel ];
    [ certPanel runModalForCertificates: @[ ( __bridge id )itemAwakedFromPersistentData ] showGroup: YES ];
#endif

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
    NSLog( @"Error Code %u: %@", resultCode, SecCopyErrorMessageString( resultCode, NULL ) );
    SecKeychainRef newKeychain = NULL;
    char const* keychainPath = "/Users/EsquireTongG/CertsForKeychainLab/NSTongG.keychain";
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

#pragma mark IBActions
- ( IBAction ) clickedSegForNormalKeychianItem: ( NSSegmentedControl* )_Sender
    {
    NSInteger selectedIndex = [ _Sender selectedSegment ];

    switch ( selectedIndex )
        {
        case 0: [ self testingForSecItemAdd ];              break;
        case 1: [ self testingForSecItemDelete ];           break;
        case 2: [ self testingForSecItemCopyMatching ];     break;
        case 3: [ self testingForSecItemUpdate ];           break;
        }
    }

- ( IBAction ) clickedSegForCertificatesItem: ( NSSegmentedControl* )_Sender
    {
    NSInteger selectedIndex = [ _Sender selectedSegment ];
    NSError* err = nil;

    switch ( selectedIndex )
        {
        case 0: [ self addNewCertificate ];     break;
        case 2:
            {
            [ self findCertificate: &err ];

            if ( err )
                [ self presentError: err ];
            } break;
        }
    }

- ( void ) addNewCertificate
    {
    OSStatus resultCode = errSecSuccess;

    CFDictionaryRef attributes = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass                 : ( __bridge id )kSecClassCertificate
         , ( __bridge id )kSecAttrCertificateType   : @( CSSM_CERT_X_509v3 )
         , ( __bridge id )kSecAttrLabel             : @"Check Check Check!"
         , ( __bridge id )kSecReturnRef             : ( __bridge id )kCFBooleanTrue
         };

    CFTypeRef results = NULL;
    resultCode = SecItemAdd( attributes, &results );

    if ( resultCode == errSecSuccess && results )
        {
        NSLog( @"%@", ( __bridge id )results );
        }
    else
        {
        printErr( resultCode );
        abort();
        }
    }

- ( SecCertificateRef ) findCertificate: ( NSError** )_Error
    {
    OSStatus resultCode = errSecSuccess;
    SecCertificateRef certificate = NULL;

    SecKeychainRef NSTongG_Keychain = NULL;
    SecKeychainRef defaultKeychianForCurrentUser = NULL;
    resultCode = SecKeychainOpen( "/Users/EsquireTongG/CertsForKeychainLab/NSTongG.keychain", &NSTongG_Keychain );
    resultCode = resultCode ?: SecKeychainCopyDefault( &defaultKeychianForCurrentUser );
    if ( resultCode != errSecSuccess || !NSTongG_Keychain )
        {
        printErr( resultCode );
        return NULL;
        }

    CFDictionaryRef queryAttrList = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecClass                         : ( __bridge id )kSecClassCertificate
//         , ( __bridge id )kSecMatchSubjectContains          : @"Mac Developer: Tong Guo (8ZDY95NQGT)"
         , ( __bridge id )kSecMatchSubjectContains          : @"deviceid.apple.com"
//         , ( __bridge id )kSecMatchSubjectContains          : @"FuckFuckGo"
         , ( __bridge id )kSecMatchLimit                    : ( __bridge id )kSecMatchLimitOne
         , ( __bridge id )kSecMatchSearchList               : @[ ( __bridge id )NSTongG_Keychain, ( __bridge id )defaultKeychianForCurrentUser ]
         , ( __bridge id )kSecReturnRef                     : ( __bridge id )kCFBooleanTrue
         };

    resultCode = SecItemCopyMatching( queryAttrList, ( CFTypeRef* )&certificate );

    if ( resultCode != errSecSuccess  )
        {
        if ( _Error )
            {
            NSMutableString* failureReason = [ ( __bridge NSString* )SecCopyErrorMessageString( resultCode, NULL ) mutableCopy ];
            NSString* beginningLetter = [ failureReason substringToIndex: 1 ];
            [ failureReason replaceCharactersInRange: NSMakeRange( 0, 1 )
                                          withString: [ beginningLetter lowercaseString ] ];
            [ failureReason insertString: NSLocalizedString( @"Because ", nil ) atIndex: 0 ];

            *_Error = [ NSError errorWithDomain: NSOSStatusErrorDomain
                                           code: ( NSInteger )resultCode
                                       userInfo: @{ NSLocalizedFailureReasonErrorKey : failureReason } ];
            }
        }

    return certificate;
    }

- ( IBAction ) evaluateTrust: ( id )_Sender
    {
    OSStatus resultCode = errSecSuccess;

    CSSM_OID const x509PolicyOID = CSSMOID_APPLE_X509_BASIC;
//    CSSM_OID const kerberosClientPolicyOID = CSSMOID_APPLE_TP_PKINIT_CLIENT;
//    CSSM_OID const kerberosServerPolicyOID = CSSMOID_APPLE_TP_PKINIT_SERVER;
//    CSSM_OID const codesignPolicyOID = CSSMOID_APPLE_TP_CODE_SIGNING;
//    CSSM_OID const packageSigningPolicyOID = CSSMOID_APPLE_TP_PACKAGE_SIGNING;
//    CSSM_OID const timeStampingPolicyOID = CSSMOID_APPLE_TP_TIMESTAMPING;

    SecPolicyRef x509Policy = [ self findPolicyWithOID: &x509PolicyOID status: &resultCode ];
//    SecPolicyRef kerberosClientPolicy = [ self findPolicyWithOID: &kerberosClientPolicyOID status: &resultCode ];
//    SecPolicyRef kerberosServerPolicy = [ self findPolicyWithOID: &kerberosServerPolicyOID status: &resultCode ];
//    SecPolicyRef codesignPolicy = [ self findPolicyWithOID: &codesignPolicyOID status: &resultCode ];
//    SecPolicyRef packageSigningPolicy = [ self findPolicyWithOID: &packageSigningPolicyOID status: &resultCode ];
//    SecPolicyRef timeStampingPolicy = [ self findPolicyWithOID: &timeStampingPolicyOID status: &resultCode ];

//    SecPolicyRef SSLPolicy = SecPolicyCreateSSL( YES, CFSTR( "https://www.oschina.net" ) );
//    NSLog( @"Policy: %@", ( __bridge NSDictionary* )SecPolicyCopyProperties( X509Policy ) );
//    NSLog( @"Policy: %@", ( __bridge NSDictionary* )SecPolicyCopyProperties( SSLPolicy ) );
    if ( resultCode != errSecSuccess )
        printErr( resultCode );
    else
        {
        NSError* err = nil;
        SecCertificateRef certificate = [ self findCertificate: &err ];

        CFArrayRef certs = ( CFArrayRef )@[ ( __bridge id )certificate ];
        CFArrayRef policies = ( CFArrayRef )@[ ( __bridge id )x509Policy
//                                             , ( __bridge id )kerberosClientPolicy
//                                             , ( __bridge id )kerberosServerPolicy
//                                             , ( __bridge id )codesignPolicy
//                                             , ( __bridge id )packageSigningPolicy
//                                             , ( __bridge id )timeStampingPolicy
                                             ];
        if ( err )
            {
            [ self presentError: err ];
            return;
            }

        SecTrustRef trust = NULL;
        resultCode = SecTrustCreateWithCertificates( certs, policies, &trust );
        if ( resultCode == errSecSuccess )
            {
//            CFAbsoluteTime expiredDate = 0;
//            CFDateRef cfDate = NULL;
//            expiredDate = 157680000;    // Second since 1 Jan 2001
//            cfDate = CFDateCreate( NULL, expiredDate );
//            NSLog( @"%@", ( __bridge NSDate* )cfDate );

//            NSDate* eprDate = [ NSDate dateWithNaturalLanguageString: @"2014-12-12" ];
//            NSLog( @"%@", eprDate );
//            SecTrustSetVerifyDate( trust, ( __bridge CFDateRef )eprDate );

            CFStringRef commonName = NULL;
            resultCode = SecCertificateCopyCommonName( certificate, &commonName );

            CSSM_APPLE_TP_ACTION_DATA actionDataStruct = { CSSM_APPLE_TP_ACTION_VERSION, CSSM_TP_ACTION_ALLOW_EXPIRED | CSSM_TP_ACTION_ALLOW_EXPIRED_ROOT };
            CFDataRef actionData = ( __bridge CFDataRef )[ NSData dataWithBytes: &actionDataStruct length: sizeof( actionData ) ];

            SecTrustSetParameters( trust, CSSM_TP_ACTION_DEFAULT, actionData );

            SecTrustResultType resultType = 0;
            SecTrustEvaluate( trust, &resultType );
            NSLog( @"%d", resultType );

            CSSM_TP_APPLE_CERT_STATUS allStatusBits = 0x0;
            if ( resultType == kSecTrustResultRecoverableTrustFailure
                    || resultType == kSecTrustResultUnspecified )
                {
                CSSM_TP_APPLE_EVIDENCE_INFO* statusChain = NULL;
                CFArrayRef certChain = NULL;
                SecTrustGetResult( trust, &resultType, &certChain, &statusChain );
                NSLog( @"%@", ( __bridge NSArray* )certChain );

                for ( int index = 0; index < CFArrayGetCount( certChain ); index++ )
                    {
                    NSLog( @"%x", statusChain[ index ].StatusBits );
                    allStatusBits = allStatusBits | statusChain[ index ].StatusBits;
                    }

                if ( allStatusBits & CSSM_CERT_STATUS_EXPIRED )
                    NSLog( @"Expired" );
                else
                    NSLog( @"Unexpired" );
                }

            SFCertificateTrustPanel* trustPanel = [ SFCertificateTrustPanel sharedCertificateTrustPanel ];
            [ trustPanel setInformativeText: NSLocalizedString( @"The certificate will be marked as trusted for the current user only. To change your decision later, open the certificate in Keychain Access and edit its Trust Settings", nil ) ];
            [ trustPanel runModalForTrust: trust
                                  message: NSLocalizedString( ( [ NSString stringWithFormat: @"Do you want your computer to trust certificates signed by \"%@\" from now on?", ( __bridge NSString* )commonName ] ), nil ) ];

            }
        else
            {
            NSError* error = [ NSError errorWithDomain: NSOSStatusErrorDomain
                                                  code: ( NSInteger )resultCode
                                              userInfo: nil ];
            [ self presentError: error ];
            }

        CFRelease( x509Policy );
        }
    }

- ( SecPolicyRef ) findPolicyWithOID: ( CSSM_OID const* )_PolicyOID
                              status: ( OSStatus* )_Status
    {
    OSStatus resultCode = errSecSuccess;
    SecPolicySearchRef searchRef = NULL;
    SecPolicyRef policy = NULL;

    resultCode = SecPolicySearchCreate( CSSM_CERT_X_509v3
                                      , _PolicyOID
                                      , NULL
                                      , &searchRef
                                      );
    if ( resultCode == errSecSuccess )
        {
        resultCode = SecPolicySearchCopyNext( searchRef, &policy );

        if ( searchRef )
            CFRelease( searchRef );

        if ( _Status )
            *_Status = resultCode;
        }
    else
        {
        if ( _Status )
            *_Status = resultCode;
        }

    return policy;
    }

- ( IBAction ) createCertificate: ( id )_Sender
    {
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef NSTongG_Keychain = NULL;
    if ( ( resultCode = SecKeychainOpen( "/Users/EsquireTongG/CertsForKeychainLab/NSTongG.keychain", &NSTongG_Keychain ) ) != errSecSuccess )
        {
        printErr( resultCode );
        return;
        }
    else
        NSLog( @"%@", ( __bridge id )NSTongG_Keychain );

    NSURL* certURL = [ NSURL URLWithString: @"file:///Users/EsquireTongG/CertsForKeychainLab/MacDeveloper.cer" ];

    if ( [ [ NSFileManager defaultManager ] fileExistsAtPath: certURL.path ] )
        {
        NSData* certData = [ NSData dataWithContentsOfURL: certURL ];

        SecCertificateRef certificate = SecCertificateCreateWithData( kCFAllocatorDefault, ( __bridge CFDataRef )certData );
        NSLog( @"%@", ( __bridge id )certificate );

        resultCode = SecCertificateAddToKeychain( certificate, NSTongG_Keychain );
        if ( resultCode != errSecSuccess )
            printErr( resultCode );

        CFErrorRef error = NULL;
        CFDataRef serialNumber = SecCertificateCopySerialNumber( certificate, &error );
        if ( error )
            {
            [ self presentError: ( __bridge NSError* )error ];
            return;
            }

        // Get the serial number of specified certificate
        NSLog( @"Serial Number: %@", [ [ NSString alloc ] initWithData: ( __bridge NSData* )serialNumber
                                                              encoding: NSUTF8StringEncoding ] );

        NSLog( @"Short Description: %@", SecCertificateCopyShortDescription( kCFAllocatorDefault
                                                                           , certificate
                                                                           , NULL
                                                                           ) );

        NSLog( @"Subject Summary: %@", ( __bridge NSString* )SecCertificateCopySubjectSummary( certificate ) );

        NSDictionary* values = ( __bridge NSDictionary* )SecCertificateCopyValues( certificate, NULL, NULL );
        NSLog( @"Contents: %@", values );

        NSLog( @"%@", ( __bridge id )kSecOIDAuthorityInfoAccess );

        fprintf( stdout, "\n----- Property Type Keys -----\n" );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeWarning );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeSuccess );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeSection );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeData );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeURL );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeDate );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeString );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeTitle );
        NSLog( @"%@", ( __bridge id )kSecPropertyTypeError );
        fprintf( stdout, "------------------------------\n\n" );

        NSLog( @"%@", kSecPropertyKeyType );
        NSLog( @"%@", kSecPropertyKeyLabel );
        NSLog( @"%@", kSecPropertyKeyLocalizedLabel );
        NSLog( @"%@", kSecPropertyKeyValue );

        if ( certificate )
            CFRelease( certificate );

        if ( error )
            CFRelease( error );

        if ( serialNumber )
            CFRelease( serialNumber );
        }

    if ( NSTongG_Keychain )
        CFRelease( NSTongG_Keychain );
    }

- ( SecKeychainRef ) defaultKeychain: ( NSError** )_Err
    {
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef defaultKeychain = NULL;
    resultCode = SecKeychainCopyDefault( &defaultKeychain );

    if ( resultCode == errSecSuccess )
        return defaultKeychain;
    else
        {
        if ( _Err )
            *_Err = [ NSError errorWithDomain: NSOSStatusErrorDomain
                                         code: ( NSInteger )resultCode
                                     userInfo: nil ];
        return nil;
        }
    }

- ( SecKeychainRef ) openKeychainWithURL: ( NSURL* )_URL
                                   error: ( NSError** )_Err
    {
    OSStatus resultCode = errSecSuccess;

    SecKeychainRef keychain = NULL;
    resultCode = SecKeychainOpen( [ _URL.path cStringUsingEncoding: NSUTF8StringEncoding ], &keychain );

    if ( resultCode == errSecSuccess )
        return keychain;
    else
        {
        if ( _Err )
            *_Err = [ NSError errorWithDomain: NSOSStatusErrorDomain
                                         code: ( NSInteger )resultCode
                                     userInfo: nil ];
        return nil;
        }
    }

- ( IBAction ) generateAsymetricKeyPair: ( id )_Sender
    {
#if 0
    OSStatus resultCode = errSecSuccess;

    NSError* err = nil;
    SecKeychainRef NSTongG_keychain = [ self openKeychainWithURL: [ NSURL URLWithString: @"file:///Users/EsquireTongG/CertsForKeychainLab/NSTongG.keychain" ]
                                                           error: &err ];
    if ( err )
        {
        [ self presentError: err ];
        KCLRelease( NSTongG_keychain );

        return;
        }

    SecKeyRef publicKey = NULL;
    SecKeyRef privateKey = NULL;

    CFDictionaryRef parameters = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecAttrKeyType           : ( __bridge id )kSecAttrKeyTypeRSA
         , ( __bridge id )kSecAttrKeySizeInBits     : @8192
         , (

    resultCode = SecKeyGeneratePair
#endif
    }

- ( IBAction ) generateSymetricKey: ( id )_Sender
    {
    OSStatus resultCode = errSecSuccess;

    NSError* err = nil;
    SecKeychainRef NSTongG_keychain = [ self openKeychainWithURL: [ NSURL URLWithString: @"file:///User/EsquireTongG/CertsForKeychainLab/NSTongG.keychain" ]
                                                           error: &err ];
    if ( err )
        {
        [ self presentError: err ];
        KCLRelease( NSTongG_keychain );

        return;
        }

    SecKeyRef key = NULL;
    CFDictionaryRef parameters = ( __bridge CFDictionaryRef )
        @{ ( __bridge id )kSecAttrKeyType               : ( __bridge id )kSecAttrKeyTypeAES
         , ( __bridge id )kSecAttrLabel                 : @"NSTongG's Public Key"
         , ( __bridge id )kSecAttrKeySizeInBits         : @256
         , ( __bridge id )kSecAttrIsPermanent           : ( __bridge id )kCFBooleanTrue
         };

    CFErrorRef cfError = NULL;
    key = SecKeyGenerateSymmetric( parameters, &cfError );
    if ( cfError )
        {
        [ self presentError: ( __bridge NSError* )cfError ];
        KCLRelease( cfError );
        }

    if ( resultCode == errSecSuccess )
        NSLog( @"%@", ( __bridge id )key );
    else
        printErr( resultCode );

    KCLRelease( key );
    KCLRelease( NSTongG_keychain );
    }

- ( NSError* ) willPresentError: ( NSError* )_Error
    {
    NSError* newError = nil;
    NSMutableDictionary* userInfo = [ [ _Error userInfo ] mutableCopy ];

    if ( [ _Error.domain isEqualToString: NSOSStatusErrorDomain ] )
        {
        userInfo[ NSLocalizedDescriptionKey ] = NSLocalizedString( @"The operation cannot be completed.", nil );
        userInfo[ NSLocalizedRecoverySuggestionErrorKey ] = NSLocalizedString( ( __bridge NSString* )SecCopyErrorMessageString( ( OSStatus )_Error.code, NULL  ), nil );
        newError = [ NSError errorWithDomain: [ _Error domain ]
                                        code: [ _Error code ]
                                    userInfo: userInfo ];
        return newError;
        }

    return _Error;
    }

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