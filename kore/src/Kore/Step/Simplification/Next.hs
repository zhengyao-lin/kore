{- |
Module      : Kore.Step.Simplification.Next
Description : Tools for Next pattern simplification.
Copyright   : (c) Runtime Verification, 2018
License     : NCSA
Maintainer  : virgil.serbanuta@runtimeverification.com
Stability   : experimental
Portability : portable
-}
module Kore.Step.Simplification.Next (
    simplify,
    mkNextDistributeOr,
) where

import Kore.Internal.OrPattern (
    OrPattern,
 )
import qualified Kore.Internal.OrPattern as OrPattern
import qualified Kore.Internal.Pattern as Pattern
import Kore.Internal.TermLike
import qualified Kore.Internal.TermLike as TermLike (
    markSimplified,
 )
import Kore.Rewriting.RewritingVariable (
    RewritingVariableName,
 )
import Prelude.Kore

-- TODO: Move Next up in the other simplifiers or something similar. Note
-- that it messes up top/bottom testing so moving it up must be done
-- immediately after evaluating the children.

{- |'simplify' simplifies a 'Next' pattern with an 'OrPattern'
child.

Right now this does not do any actual simplification.
-}
simplify ::
    Next Sort (OrPattern RewritingVariableName) ->
    OrPattern RewritingVariableName
simplify Next{nextChild = child} = simplifyEvaluated child

simplifyEvaluated ::
    OrPattern RewritingVariableName ->
    OrPattern RewritingVariableName
simplifyEvaluated simplified =
    OrPattern.fromTermLike $
        TermLike.markSimplified $
            mkNextDistributeOr $
                Pattern.toTermLike $
                    OrPattern.toPattern simplified

mkNextDistributeOr ::
    TermLike RewritingVariableName -> TermLike RewritingVariableName
mkNextDistributeOr (TermLike (attrs :< OrF Or{orSort, orFirst, orSecond})) =
    TermLike
        ( attrs
            :< OrF
                ( Or
                    orSort
                    (mkNextDistributeOr orFirst)
                    (mkNextDistributeOr orSecond)
                )
        )
mkNextDistributeOr term = mkNext term
