//
//  Tailor.h
//  Tailor
//
//  Created by John Brownlee on 11/10/14.
//  Copyright (c) 2014 John Brownlee. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Tailor.
FOUNDATION_EXPORT double TailorVersionNumber;

//! Project version string for Tailor.
FOUNDATION_EXPORT const unsigned char TailorVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Tailor/PublicHeader.h>

#include "TailorC.h"
#include "crypt_blowfish.h"
#include <mysql.h>