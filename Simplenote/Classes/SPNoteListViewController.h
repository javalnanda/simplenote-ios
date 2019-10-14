#import <UIKit/UIKit.h>
#import "SPTransitionController.h"
#import "SPSidebarContainerViewController.h"
#import "Note.h"

@class SPEmptyListView;

typedef NS_ENUM(NSInteger, SPTagFilterType) {
	SPTagFilterTypeUserTag = 0,
	SPTagFilterTypeDeleted = 1,
	SPTagFilterTypeShared = 2,
    SPTagFilterTypePinned = 3,
    SPTagFilterTypeUnread = 4,
    SPTagFilterTypeUntagged = 5
};

@interface SPNoteListViewController : UIViewController<SPSidebarContainerDelegate> {

    NSTimer *searchTimer;

    // Bools
    BOOL bSearching;
    BOOL bListViewIsEmpty;
    BOOL bIndexingNotes;
    BOOL bShouldShowSidePanel;

    SPTagFilterType tagFilterType;
}

@property (nonatomic, strong, readonly) UIGestureRecognizer         *panGestureRecognizer;
@property (nonatomic, strong) NSFetchedResultsController<Note *>    *fetchedResultsController;
@property (nonatomic, strong) NSString                              *searchText;
@property (nonatomic) BOOL                                          firstLaunch;

@property (nonatomic, strong, readonly) UISearchBar                 *searchBar;
@property (nonatomic, strong) SPEmptyListView                       *emptyListView;
@property (nonatomic, strong) UITableView                           *tableView;

- (void)registerSidebarPanRecognizer:(UIGestureRecognizer *)recognizer;

- (Note *)noteForKey:(NSString *)key;
- (void)update;
- (void)openNote:(Note *)note fromIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)setWaitingForIndex:(BOOL)waiting;
- (void)endSearching;;

@end
