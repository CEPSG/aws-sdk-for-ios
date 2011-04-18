/*
 * Copyright 2010-2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "AmazonSDKUtil.h"
#import <CommonCrypto/CommonDigest.h>


static char base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation AmazonSDKUtil

+(NSString *)userAgentString
{
    NSString *sn  = [[[UIDevice currentDevice] systemName] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *sv  = [[UIDevice currentDevice] systemVersion];
    NSString *loc = [[NSLocale currentLocale] localeIdentifier];
    NSString *ua  = [NSString stringWithFormat: [NSString stringWithString:AWS_SDK_USER_AGENT_FORMAT], [NSString stringWithString:AWS_SDK_VERSION], sn, sv, loc];

    return ua;
}

+(NSString *)urlEncode:(NSString *)input
{
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)input, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);

    return [encoded autorelease];
}

+(NSString *)MIMETypeForExtension:(NSString *)extension
{
    static NSDictionary *lookupTable = nil;

    if (lookupTable == nil) {
        lookupTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"application/postscript", @"ai",
                       @"audio/x-aiff", @"aif",
                       @"audio/x-aiff", @"aifc",
                       @"audio/x-aiff", @"aiff",
                       @"text/plain", @"asc",
                       @"audio/basic", @"au",
                       @"video/x-msvideo", @"avi",
                       @"application/x-bcpio", @"bcpio",
                       @"application/octet-stream", @"bin",
                       @"text/plain", @"c",
                       @"text/plain", @"cc",
                       @"application/clariscad", @"ccad",
                       @"application/x-netcdf", @"cdf",
                       @"application/octet-stream", @"class",
                       @"application/x-cpio", @"cpio",
                       @"text/plain", @"cpp",
                       @"application/mac-compactpro", @"cpt",
                       @"text/plain", @"cs",
                       @"application/x-csh", @"csh",
                       @"text/css", @"css",
                       @"application/x-director", @"dcr",
                       @"application/x-director", @"dir",
                       @"application/octet-stream", @"dms",
                       @"application/msword", @"doc",
                       @"application/msword", @"docx",
                       @"application/msword", @"dot",
                       @"application/drafting", @"drw",
                       @"application/x-dvi", @"dvi",
                       @"application/acad", @"dwg",
                       @"application/dxf", @"dxf",
                       @"application/x-director", @"dxr",
                       @"application/postscript", @"eps",
                       @"text/x-setext", @"etx",
                       @"application/octet-stream", @"exe",
                       @"application/andrew-inset", @"ez",
                       @"text/plain", @"f",
                       @"text/plain", @"f90",
                       @"video/x-fli", @"fli",
                       @"image/gif", @"gif",
                       @"application/x-gtar", @"gtar",
                       @"application/x-gzip", @"gz",
                       @"text/plain", @"h",
                       @"application/x-hdf", @"hdf",
                       @"text/plain", @"hh",
                       @"application/mac-binhex40", @"hqx",
                       @"text/html", @"htm",
                       @"text/html", @"html",
                       @"x-conference/x-cooltalk", @"ice",
                       @"image/ief", @"ief",
                       @"model/iges", @"iges",
                       @"model/iges", @"igs",
                       @"application/x-ipscript", @"ips",
                       @"application/x-ipix", @"ipx",
                       @"image/jpeg", @"jpe",
                       @"image/jpeg", @"jpeg",
                       @"image/jpeg", @"jpg",
                       @"application/x-javascript", @"js",
                       @"audio/midi", @"kar",
                       @"application/x-latex", @"latex",
                       @"application/octet-stream", @"lha",
                       @"application/x-lisp", @"lsp",
                       @"application/octet-stream", @"lzh",
                       @"text/plain", @"m",
                       @"application/x-troff-man", @"man",
                       @"application/x-troff-me", @"me",
                       @"model/mesh", @"mesh",
                       @"audio/midi", @"mid",
                       @"audio/midi", @"midi",
                       @"www/mime", @"mime",
                       @"video/quicktime", @"mov",
                       @"video/x-sgi-movie", @"movie",
                       @"audio/mpeg", @"mp2",
                       @"audio/mpeg", @"mp3",
                       @"video/mpeg", @"mpe",
                       @"video/mpeg", @"mpeg",
                       @"video/mpeg", @"mpg",
                       @"audio/mpeg", @"mpga",
                       @"application/x-troff-ms", @"ms",
                       @"application/x-ole-storage", @"msi",
                       @"model/mesh", @"msh",
                       @"application/x-netcdf", @"nc",
                       @"application/oda", @"oda",
                       @"image/x-portable-bitmap", @"pbm",
                       @"chemical/x-pdb", @"pdb",
                       @"application/pdf", @"pdf",
                       @"image/x-portable-graymap", @"pgm",
                       @"application/x-chess-pgn", @"pgn",
                       @"image/png", @"png",
                       @"image/x-portable-anymap", @"pnm",
                       @"application/mspowerpoint", @"pot",
                       @"image/x-portable-pixmap", @"ppm",
                       @"application/mspowerpoint", @"pps",
                       @"application/mspowerpoint", @"ppt",
                       @"application/mspowerpoint", @"ppz",
                       @"application/x-freelance", @"pre",
                       @"application/pro_eng", @"prt",
                       @"application/postscript", @"ps",
                       @"video/quicktime", @"qt",
                       @"audio/x-realaudio", @"ra",
                       @"audio/x-pn-realaudio", @"ram",
                       @"image/cmu-raster", @"ras",
                       @"image/x-rgb", @"rgb",
                       @"audio/x-pn-realaudio", @"rm",
                       @"application/x-troff", @"roff",
                       @"audio/x-pn-realaudio-plugin", @"rpm",
                       @"text/rtf", @"rtf",
                       @"text/richtext", @"rtx",
                       @"application/x-lotusscreencam", @"scm",
                       @"application/set", @"set",
                       @"text/sgml", @"sgm",
                       @"text/sgml", @"sgml",
                       @"application/x-sh", @"sh",
                       @"application/x-shar", @"shar",
                       @"model/mesh", @"silo",
                       @"application/x-stuffit", @"sit",
                       @"application/x-koan", @"skd",
                       @"application/x-koan", @"skm",
                       @"application/x-koan", @"skp",
                       @"application/x-koan", @"skt",
                       @"application/smil", @"smi",
                       @"application/smil", @"smil",
                       @"audio/basic", @"snd",
                       @"application/solids", @"sol",
                       @"application/x-futuresplash", @"spl",
                       @"application/x-wais-source", @"src",
                       @"application/STEP", @"step",
                       @"application/SLA", @"stl",
                       @"application/STEP", @"stp",
                       @"application/x-sv4cpio", @"sv4cpio",
                       @"application/x-sv4crc", @"sv4crc",
                       @"application/x-shockwave-flash", @"swf",
                       @"application/x-troff", @"t",
                       @"application/x-tar", @"tar",
                       @"application/x-tcl", @"tcl",
                       @"application/x-tex", @"tex",
                       @"image/tiff", @"tif",
                       @"image/tiff", @"tiff",
                       @"application/x-troff", @"tr",
                       @"audio/TSP-audio", @"tsi",
                       @"application/dsptype", @"tsp",
                       @"text/tab-separated-values", @"tsv",
                       @"text/plain", @"txt",
                       @"application/i-deas", @"unv",
                       @"application/x-ustar", @"ustar",
                       @"application/x-cdlink", @"vcd",
                       @"application/vda", @"vda",
                       @"model/vrml", @"vrml",
                       @"audio/x-wav", @"wav",
                       @"model/vrml", @"wrl",
                       @"image/x-xbitmap", @"xbm",
                       @"application/vnd.ms-excel", @"xlc",
                       @"application/vnd.ms-excel", @"xll",
                       @"application/vnd.ms-excel", @"xlm",
                       @"application/vnd.ms-excel", @"xls",
                       @"application/vnd.ms-excel", @"xlw",
                       @"text/xml", @"xml",
                       @"image/x-xpixmap", @"xpm",
                       @"image/x-xwindowdump", @"xwd",
                       @"chemical/x-pdb", @"xyz",
                       @"application/zip", @"zip",
                       @"video/x-m4v", @"m4v",
                       @"video/webm", @"webm",
                       @"video/ogv", @"ogv",
                       nil];
    }
    NSString *mimetype = (NSString *)[lookupTable objectForKey:extension];
    return mimetype == nil ? @"application/octet-stream" : mimetype;
}

+(NSNumber *)convertStringToNumber:(NSString *)string
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];

    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLocale:[AmazonSDKUtil timestampLocale]];

    return [formatter numberFromString:string];
}

+(NSDate *)convertStringToDate:(NSString *)string
{
    NSDate *date = [AmazonSDKUtil convertStringToDate:string usingFormat:kISO8061DateFormat];

    if (date != nil) {
        return date;
    }
    else {
        return [AmazonSDKUtil convertStringToDate:string usingFormat:kISO8601DateFormat];
    }
}

+(NSDate *)convertStringToDate:(NSString *)string usingFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];

    NSDate *parsed = [dateFormatter dateFromString:string];

    [dateFormatter release];

    return parsed;
}

+(NSURL *)URLWithURL:(NSURL *)theURL andProtocol:(NSString *)theProtocol
{
    if (!([theProtocol isEqualToString:@"http"] || [theProtocol isEqualToString:@"https"])) {
        @throw [AmazonClientException exceptionWithMessage : @"protocol must be 'http' or 'https'."];
    }

    NSString *currentURL = [theURL absoluteString];
    if (![currentURL hasPrefix:[NSString stringWithFormat:@"%@:", theProtocol]]) {
        NSString *pattern;
        if ([theProtocol isEqualToString:@"http"]) {
            pattern = @"https://";
        }
        else {
            pattern = @"http://";
        }

        return [NSURL URLWithString:[currentURL stringByReplacingOccurrencesOfString:pattern
                                     withString:[NSString stringWithFormat:@"%@://", theProtocol]
                                     options:0
                                     range:NSMakeRange(0, 8)]];
    }

    return [NSURL URLWithString:[theURL absoluteString]];
}

+(NSLocale *)timestampLocale
{
    static NSLocale *_tsLoc = nil;

    if (nil == _tsLoc) {
        _tsLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    return _tsLoc;
}

@end

@implementation NSDate (WithISO8061Format)

-(NSString *)stringWithISO8061Format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:kISO8061DateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];

    NSString *formatted = [dateFormatter stringFromDate:self];

    [dateFormatter release];

    return formatted;
}

-(NSString *)stringWithISO8601Format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:kISO8601DateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];

    NSString *formatted = [dateFormatter stringFromDate:self];

    [dateFormatter release];

    return formatted;
}

-(NSString *)stringWithRFC822Format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:kRFC822DateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];

    NSString *formatted = [dateFormatter stringFromDate:self];

    [dateFormatter release];

    return formatted;
}

+(NSDate *)dateWithISO8061Format:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:kISO8061DateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];

    NSDate *parsed = [dateFormatter dateFromString:dateString];

    [dateFormatter release];

    return parsed;
}

+(NSString *)ISO8061FormattedCurrentTimestamp
{
    return [[NSDate date] stringWithISO8061Format];
}


@end

@implementation NSString (AmazonSDKUtil)

-(NSString *)stringByNormalizingPathComponent
{
    return [self stringByReplacingOccurrencesOfString:@"+" withString:@"\%2B"];
}

-(NSString *)stringWithURLEncoding
{
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=$,/?%#[]% ", kCFStringEncodingUTF8);

    [encoded autorelease];
    return [encoded stringByNormalizingPathComponent];
}

@end


@implementation NSData (WithBase64)

-(NSString *) base64EncodedString
{
    NSMutableString *result;
    unsigned char   *raw;
    unsigned long   length;
    short           i, nCharsToWrite;
    long            cursor;
    unsigned char   inbytes[3], outbytes[4];

    length = [self length];

    if (length < 1) {
        return @"";
    }

    result = [NSMutableString stringWithCapacity:length];
    raw    = (unsigned char *)[self bytes];
    // Take 3 chars at a time, and encode to 4
    for (cursor = 0; cursor < length; cursor += 3) {
        for (i = 0; i < 3; i++) {
            if (cursor + i < length) {
                inbytes[i] = raw[cursor + i];
            }
            else{
                inbytes[i] = 0;
            }
        }

        outbytes[0] = (inbytes[0] & 0xFC) >> 2;
        outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
        outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
        outbytes[3] = inbytes[2] & 0x3F;

        nCharsToWrite = 4;

        switch (length - cursor) {
        case 1:
            nCharsToWrite = 2;
            break;

        case 2:
            nCharsToWrite = 3;
            break;
        }
        for (i = 0; i < nCharsToWrite; i++) {
            [result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
        }
        for (i = nCharsToWrite; i < 4; i++) {
            [result appendString:@"="];
        }
    }

    return [NSString stringWithString:result]; // convert to immutable string
}

@end


