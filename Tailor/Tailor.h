#import <Foundation/Foundation.h>

//! Project version number for Tailor.
FOUNDATION_EXPORT double TailorVersionNumber;

//! Project version string for Tailor.
FOUNDATION_EXPORT const unsigned char TailorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Tailor/PublicHeader.h>

extern void CC_SHA512(const void *data, unsigned int len, unsigned char *md);
size_t CC_MD5_DIGEST_LENGTH = 16;
extern unsigned char * CC_MD5(const void *data, long long len, unsigned char *md);