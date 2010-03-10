#import <Foundation/Foundation.h>

@interface NuOperator : NSObject
{
}

- (id) evalWithArguments:(id) cdr context:(NSMutableDictionary *) context;
- (id) callWithArguments:(id) cdr context:(NSMutableDictionary *) context;
@end

@interface NuMarkupOperator : NuOperator
{
    NSString *tag;
    NSString *prefix;
    BOOL empty;
}

- (id) initWithTag:(NSString *) tag;
- (id) initWithTag:(NSString *) tag prefix:(NSString *) prefix;
- (void) setEmpty:(BOOL) e;
@end

@implementation NuMarkupOperator

+ (id) operatorWithTag:(NSString *) _tag
{
    return [[[self alloc] initWithTag:_tag] autorelease];
}

+ (id) operatorWithTag:(NSString *) _tag prefix:(NSString *) _prefix
{
    return [[[self alloc] initWithTag:_tag prefix:_prefix] autorelease];
}

- (id) initWithTag:(NSString *) _tag
{
    return [self initWithTag:_tag prefix:nil];
}

- (id) initWithTag:(NSString *) _tag prefix:(NSString *) _prefix
{
    self = [super init];
    tag = _tag ? [_tag retain] : @"undefined-element";
    prefix = _prefix ? [_prefix retain] : @"";
    return self;
}

- (void) setEmpty:(BOOL) e {
   empty = e;
}

- (id) callWithArguments:(id)cdr context:(NSMutableDictionary *)context
{
    NSMutableString *body = [NSMutableString string];
    NSMutableString *attributes = [NSMutableString string];

    static id NuSymbol = nil;
    if (!NuSymbol) {
        NuSymbol = NSClassFromString(@"NuSymbol");
    }

    id cursor = cdr;
    while (cursor && (cursor != [NSNull null])) {
        id item = [cursor car];
        if ([item isKindOfClass:[NuSymbol class]] && [item isLabel]) {
            cursor = [cursor cdr];
            if (cursor && (cursor != [NSNull null])) {
                id value = [[cursor car] evalWithContext:context];
                [attributes appendFormat:@" %@=\"%@\"", [item labelName], [value stringValue]];
            }
        }
        else {
            id evaluatedItem = [item evalWithContext:context];
            if ([evaluatedItem isKindOfClass:[NSString class]]) {
                [body appendString:evaluatedItem];
            }
            else if ([evaluatedItem isKindOfClass:[NSArray class]]) {
                int max = [evaluatedItem count];
                for (int i = 0; i < max; i++) {
                    [body appendString:[evaluatedItem objectAtIndex:i]];
                }
            }
            else if (evaluatedItem == [NSNull null]) {
               // do nothing
            }
            else {
                [body appendString:[evaluatedItem stringValue]];
            }
        }
        if (cursor && (cursor != [NSNull null]))
            cursor = [cursor cdr];
    }

    if ([body length] || !empty) {
        return [NSString stringWithFormat:@"%@<%@%@>%@</%@>", prefix, tag, attributes, body, tag];
    }
    else {
        return [NSString stringWithFormat:@"%@<%@%@/>", prefix, tag, attributes];
    }
}

@end
