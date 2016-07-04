//
//  LCUser+CoreDataProperties.h
//  
//
//  Created by Viktor Drykin on 03.07.16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "LCUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface LCUser (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *firstName;
@property (nullable, nonatomic, retain) NSString *lastName;
@property (nullable, nonatomic, retain) NSString *photoURL;
@property (nullable, nonatomic, retain) NSString *userId;
@property (nullable, nonatomic, retain) NSSet<LCFriend *> *friends;

@end

@interface LCUser (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(LCFriend *)value;
- (void)removeFriendsObject:(LCFriend *)value;
- (void)addFriends:(NSSet<LCFriend *> *)values;
- (void)removeFriends:(NSSet<LCFriend *> *)values;

@end

NS_ASSUME_NONNULL_END
