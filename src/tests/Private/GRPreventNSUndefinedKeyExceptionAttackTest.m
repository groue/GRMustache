// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRPreventNSUndefinedKeyExceptionAttackTest.h"
#import "GRMustache_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheContext_private.h"
#import <CoreData/CoreData.h>

@interface GRPreventNSUndefinedKeyExceptionAttackTest()
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@end

@implementation GRPreventNSUndefinedKeyExceptionAttackTest
@synthesize managedObjectModel=_managedObjectModel;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;
@synthesize managedObjectContext=_managedObjectContext;

- (void)setUp
{
    self.managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:[NSArray arrayWithObject:self.testBundle]];
    self.persistentStoreCoordinator = [[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel] autorelease];
    self.managedObjectContext = [[[NSManagedObjectContext alloc] init] autorelease];
    [self.managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
}

- (void)tearDown
{
    self.managedObjectModel = nil;
    self.persistentStoreCoordinator = nil;
    self.managedObjectContext = nil;
}

- (void)testNSUndefinedKeyExceptionSilencing
{
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"foo:{{foo}}" error:nil];
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"NSManagedObject" inManagedObjectContext:self.managedObjectContext];
    id object = [[[NSObject alloc] init] autorelease];
    
    
    // GRMustacheContext should catch exceptions
    
    GRMustacheContextDidCatchNSUndefinedKeyException = NO;
    [template renderObject:object];
    STAssertEquals(YES, GRMustacheContextDidCatchNSUndefinedKeyException, @"");
    
    GRMustacheContextDidCatchNSUndefinedKeyException = NO;
    [template renderObject:managedObject];
    STAssertEquals(YES, GRMustacheContextDidCatchNSUndefinedKeyException, @"");
    
    
    // Now GRMustacheContext should not catch any exception
    
    [GRMustache preventNSUndefinedKeyExceptionAttack];
    
    GRMustacheContextDidCatchNSUndefinedKeyException = NO;
    [template renderObject:object];
    STAssertEquals(NO, GRMustacheContextDidCatchNSUndefinedKeyException, @"");
    
    GRMustacheContextDidCatchNSUndefinedKeyException = NO;
    [template renderObject:managedObject];
    STAssertEquals(NO, GRMustacheContextDidCatchNSUndefinedKeyException, @"");

    
    // Regression test: until 1.7.2, NSUndefinedKeyException guard would prevent rendering nil object
    
    STAssertEqualObjects([template render], @"foo:", nil);
    STAssertEqualObjects([template renderObject:nil], @"foo:", nil);
}

@end
