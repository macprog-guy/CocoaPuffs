
#import "NUFunctions.h"

// ----------------------------------------------------------------------------
   #pragma mark Math Functions
// ----------------------------------------------------------------------------

double fclamp(double lower, double value, double upper)
{
    return fmin(fmax(lower, value), upper);
}
