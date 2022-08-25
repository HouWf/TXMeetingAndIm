#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "MeetingLocalized.h"
#import "IMProtocol.h"
#import "TXMeetingPair.h"
#import "TXRoomService.h"
#import "TRTCMeeting.h"
#import "TRTCMeetingDef.h"
#import "TRTCMeetingDelegate.h"
#import "TUIMeetingKit.h"

FOUNDATION_EXPORT double TUIMeetingVersionNumber;
FOUNDATION_EXPORT const unsigned char TUIMeetingVersionString[];

