# Insufficient Balance When Purchasing Savings Plans

## Problem

Users may see an "insufficient balance" error when trying to purchase a savings plan (such as an annual A40 Pod savings plan), even when their account balance appears to match the displayed plan price exactly.

**Example scenario:** A user adds $1,752.00 to their account and tries to deploy an A40 Pod under a 1-year savings plan that shows a total price of $1,752.00. Despite the balance matching the displayed price, the system reports "insufficient balance."

## Why This Happens

Even a difference of just a few cents can prevent the purchase from going through. The account balance cannot be exactly equal to the plan price because users must also cover:

1. **Storage costs** - Pod storage incurs additional charges beyond the base plan price. The savings plan only covers GPU compute, not storage, so users need extra balance to cover their storage allocation.
2. **Per-hour rounding** - Minor rounding in per-hour billing calculations can create small overages
3. **Safety margin** - The system requires a small buffer to ensure the plan can be fulfilled without interruption

Users need to add a small amount extra beyond the displayed plan price (typically $10-20 depending on the plan size and storage needs).

## Important Clarification

**This is NOT caused by taxes.** Do not suggest taxes as the reason for this mismatch. Runpod does not add taxes to the displayed savings plan prices for most users. The insufficient balance is purely due to the buffer requirement for storage and rounding.

## Solution

To resolve this issue, users should:

1. Add a small additional amount to their account balance (recommend $10-20 extra beyond the plan price)
2. Retry the savings plan purchase

## Example Response

If a user asks why they see "insufficient balance" when their balance matches the plan price:

> The system requires a small buffer beyond the displayed plan price to account for potential storage costs and minor billing rounding. I recommend adding an extra $10-20 to your account balance and trying again. This is not related to taxes - it's simply a safety margin the system requires to ensure your plan can be fulfilled without interruption.
