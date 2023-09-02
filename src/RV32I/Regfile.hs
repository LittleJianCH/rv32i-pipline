module RV32I.Regfile (
  regfile
) where

import Clash.Prelude

import RV32I.Types (Reg, BV32)
import Data.Function (on)

regfile
  :: forall dom. HiddenClockResetEnable dom
  => Signal dom Reg
  -> Signal dom Reg
  -> Signal dom Reg
  -> Signal dom BV32
  -> Signal dom (BV32, BV32)
regfile addrA addrB addrW dataW = view <*> regVec
  where
    regVec :: Signal dom (Vec 32 BV32)
    regVec = register (repeat 0) (liftA3 replace addrW dataW regVec)

    visit :: Reg -> Vec 32 BV32 -> BV32
    visit 0 _    = 0
    visit n regs = regs !! n

    view :: Signal dom (Vec 32 BV32 -> (BV32, BV32))
    view = uncurry (liftA2 (,)) <$> (liftA2 (,) `on` (visit <$>)) addrA addrB
