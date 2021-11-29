/// The *script* part of the script, e.g. the stuff that
/// runs the komodor runner.
///
/// If *this* changes then the template should be updated
///
public func renderScript(_ hookName: String, _ searchPaths: [String] = []) -> String {
  let paths = searchPaths.map { "'\($0)'" }.joined(separator: " ")
  
  return
        """
        hookName=`basename "$0"`
        gitParams="$*"
        
        # use prebuilt binary if one exists, preferring release
        builds=( '.build/release/komondor' '.build/debug/komondor' \(paths) )
        for build in ${builds[@]} ; do
          if [[ -e $build ]] ; then
            komondor=$build
            break
          fi
        done
        
        # run hook
        $komondor run \(hookName) $gitParams
        """
}
