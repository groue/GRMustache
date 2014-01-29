// The MIT License
// 
// Copyright (c) 2014 Gwendal Roué
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

#import "GRMustachePrivateAPITest.h"
#import "GRMustache_private.h"
#import "GRMustacheTemplate_private.h"
#import "GRMustacheKeyAccess_private.h"
#import <CoreData/CoreData.h>

@interface GRPreventNSUndefinedKeyExceptionAttackTest : GRMustachePrivateAPITest {
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectContext *_managedObjectContext;
}
@end

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

- (void)testNSUndefinedKeyExceptionPrevention
{
    [GRMustache preventNSUndefinedKeyExceptionAttack];
    
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:@"foo:{{foo}}" error:nil];
    {
        GRMustacheKeyAccessDidCatchNSUndefinedKeyException = NO;
        id object = [[[NSObject alloc] init] autorelease];
        [template renderObject:object error:NULL];
        
        // make sure object did not raise any exception
        STAssertEquals(NO, GRMustacheKeyAccessDidCatchNSUndefinedKeyException, @"");
        
        // make sure object raises exception again
        STAssertThrowsSpecificNamed([object valueForKey:@"foo"], NSException, NSUndefinedKeyException, nil);
    }
    
    {
        GRMustacheKeyAccessDidCatchNSUndefinedKeyException = NO;
        NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:@"NSManagedObject" inManagedObjectContext:self.managedObjectContext];
        [template renderObject:managedObject error:NULL];
        
        // make sure object did not raise any exception
        STAssertEquals(NO, GRMustacheKeyAccessDidCatchNSUndefinedKeyException, @"");
        
        // make sure object raises exception again
        STAssertThrowsSpecificNamed([managedObject valueForKey:@"foo"], NSException, NSUndefinedKeyException, nil);
    }
    
    // Regression test: until 1.7.2, NSUndefinedKeyException prevention would fail with nil object
    
    STAssertEqualObjects([template renderObject:nil error:NULL], @"foo:", nil);
    STAssertEqualObjects([template renderObject:nil error:NULL], @"foo:", nil);
}

- (void)testNSUndefinedKeyExceptionPreventionInThread
{
    NSThread *thread = [[[NSThread alloc] initWithTarget:self selector:@selector(testNSUndefinedKeyExceptionPrevention) object:nil] autorelease];
    [thread start];
    while (!thread.isFinished);
}

@end
