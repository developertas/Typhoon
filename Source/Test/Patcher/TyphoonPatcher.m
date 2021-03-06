////////////////////////////////////////////////////////////////////////////////
//
//  TYPHOON FRAMEWORK
//  Copyright 2013, Typhoon Framework Contributors
//  All Rights Reserved.
//
//  NOTICE: The authors permit you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "TyphoonDefinition.h"
#import "TyphoonPatcher.h"
#import "TyphoonComponentFactory.h"
#import "TyphoonDefinition+Infrastructure.h"
#import "TyphoonRuntimeArguments.h"

@interface TyphoonPatcherDefinition : TyphoonDefinition

@property (nonatomic, strong) TyphoonPatchObjectCreationBlock patchObjectBlock;

- (id)initWithOriginalDefinition:(TyphoonDefinition *)definition patchObjectBlock:(TyphoonPatchObjectCreationBlock)patchObjectBlock;

@end

@implementation TyphoonPatcherDefinition

- (id)initWithOriginalDefinition:(TyphoonDefinition *)definition patchObjectBlock:(TyphoonPatchObjectCreationBlock)patchObjectBlock
{
    self = [super initWithClass:definition.type key:definition.key];
    if (self) {
        self.patchObjectBlock = patchObjectBlock;
        self.scope = definition.scope;
        self.autoInjectionVisibility = definition.autoInjectionVisibility;

    }
    return self;
}

- (id)targetForInitializerWithFactory:(TyphoonComponentFactory *)factory args:(TyphoonRuntimeArguments *)args
{
    return self.patchObjectBlock();
}

- (id)initializer
{
    return nil;
}

@end


@implementation TyphoonPatcher

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction

- (id)init
{
    self = [super init];
    if (self) {
        _patches = [[NSMutableDictionary alloc] init];
    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods

- (void)patchDefinitionWithKey:(NSString *)key withObject:(TyphoonPatchObjectCreationBlock)objectCreationBlock
{
    [_patches setObject:objectCreationBlock forKey:key];
}


- (void)patchDefinitionWithSelector:(SEL)definitionSelector withObject:(TyphoonPatchObjectCreationBlock)objectCreationBlock
{
    [self patchDefinitionWithKey:NSStringFromSelector(definitionSelector) withObject:objectCreationBlock];
}

- (void)detach
{
    [self rollback];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Protocol Methods

- (void)postProcessDefinitionsInFactory:(TyphoonComponentFactory *)factory
{
    [super postProcessDefinitionsInFactory:factory];

    [factory enumerateDefinitions:^(TyphoonDefinition *definition, NSUInteger index, TyphoonDefinition **definitionToReplace, BOOL *stop) {
        TyphoonPatchObjectCreationBlock patchObjectBlock = _patches[definition.key];
        if (patchObjectBlock) {
            *definitionToReplace = [[TyphoonPatcherDefinition alloc] initWithOriginalDefinition:definition patchObjectBlock:patchObjectBlock];
        }
    }];
}


@end

@implementation TyphoonPatcher(Deprecated)

- (void)patchDefinition:(TyphoonDefinition *)definition withObject:(TyphoonPatchObjectCreationBlock)objectCreationBlock
{
    [self patchDefinitionWithKey:definition.key withObject:objectCreationBlock];
}

@end