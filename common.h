#define rnd(n) (rand()%(n+1))
extern float frnd(float range);

static inline NSError *NSMakeError(NSString *domain, int code, NSString *descr, NSString *recoveryDescr) { return [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:descr, NSLocalizedDescriptionKey, recoveryDescr, NSLocalizedRecoverySuggestionErrorKey, nil]]; }

static inline NSError *CfxrMakeError(int code, NSString *descr, NSString *recoveryDescr) { return NSMakeError(@"eu.thirdcog.cfxr.ErrorDomain", code, descr, recoveryDescr); }