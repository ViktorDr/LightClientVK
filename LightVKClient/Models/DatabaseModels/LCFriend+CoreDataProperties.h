//
//  LCFriend+CoreDataProperties.h
//  
//
//  Created by Viktor Drykin on 03.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LCFriend.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCFriend (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *friendId;
@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *photoURL;
@property (nullable, nonatomic, retain) LCUser *userOwner;

@end

NS_ASSUME_NONNULL_END
