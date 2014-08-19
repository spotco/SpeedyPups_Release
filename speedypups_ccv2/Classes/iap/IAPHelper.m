#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "SpeedyPupsIAP.h"
#import "GEventDispatcher.h"

//http://www.raywenderlich.com/21081/introduction-to-in-app-purchases-in-ios-6-tutorial
@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper {
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
}

+(IAPHelper*)sharedInstance {
    static dispatch_once_t once;
    static IAPHelper* sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [SpeedyPupsIAP get_all_requested_iaps];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

-(id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
	
    if ((self = [super init])) {
        _productIdentifiers = productIdentifiers;
        _purchasedProductIdentifiers = [NSMutableSet set];
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

-(void)restoreCompletedTransactions {
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

-(void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler {
    _completionHandler = [completionHandler copy];
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"IAP Product list loaded");
    _productsRequest = nil;
	
	for (NSString *bad in response.invalidProductIdentifiers) {
		NSLog(@"INVALID IAP IDENTIFIER(%@)",bad);
	}
	
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts) {
        NSLog(@"Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
	
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
	
}

-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"IAP COULD NOT LOAD LIST OF PRODUCTS (%@)",error.localizedDescription);
    _productsRequest = nil;
    _completionHandler(NO, nil);
    _completionHandler = nil;
	
}

-(BOOL)productPurchased:(NSString *)productIdentifier {
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

-(void)buyProduct:(SKProduct *)product {
	[GEventDispatcher push_event:[GEvent cons_type:GEventType_IAP_BUY]];
	if (product == NULL) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_IAP_FAIL] add_i1:1 i2:0]];
		NSLog(@"IAP BUY FAIL ITEM NULL");
		return;
	}
    NSLog(@"IAP START BUY %@...", product.productIdentifier);
	SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSLog(@"IAP::paymentqueue update");
	for (SKPaymentTransaction * transaction in transactions) {
		
		if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
			[self completeTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
			[self failedTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStateRestored) {
			[self restoreTransaction:transaction];
			
		} else {
			NSLog(@"paymentQueue update error(%d)",transaction.transactionState);
		}
    };
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	if (error.code != SKErrorPaymentCancelled) {
		[[[UIAlertView alloc] initWithTitle:@"No purchases to restore." message:@"Buy SpeedyPups AdFree from the store!" delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
	}
}


-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
	if (queue.transactions.count == 0) [[[UIAlertView alloc] initWithTitle:@"No purchases to restore." message:@"Buy SpeedyPups AdFree from the store!" delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

-(void)completeTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"IAP SUCCESS FOR (%@)",transaction.payment.productIdentifier);
    [GEventDispatcher push_event:[GEvent cons_type:GEventType_IAP_SUCCESS]];
	[self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

-(void)restoreTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"IAP RESTORE FOR (%@)",transaction.payment.productIdentifier);
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
	[GEventDispatcher push_event:[GEvent cons_type:GEventType_IAP_SUCCESS]];
}

-(void)failedTransaction:(SKPaymentTransaction *)transaction {
    NSLog(@"IAP FAIL FOR (%@)",transaction.payment.productIdentifier);
	
	NSLog(@"ERROR: %@", transaction.error.description);	
    if (transaction.error.code != SKErrorPaymentCancelled) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_IAP_FAIL] add_i1:1 i2:0]];
    } else {
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_IAP_FAIL]];
	}
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

-(void)provideContentForProductIdentifier:(NSString*)pid {
	NSLog(@"content for %@",pid);
	[SpeedyPupsIAP content_for_key:pid];
}

@end