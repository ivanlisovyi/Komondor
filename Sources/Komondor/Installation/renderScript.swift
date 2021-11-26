/// The *script* part of the script, e.g. the stuff that
/// runs the komodor runner.
///
/// If *this* changes then the template should be updated
///
public func renderScript(_ hookName: String, _ executor: String?) -> String {
        """
        hookName=`basename "$0"`
        gitParams="$*"
        
        # run hook
        \(executor ?? "") komondor run \(hookName) $gitParams
        """
}
