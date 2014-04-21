;;; Make It Rain
;;; Tip Ether to random people who have previously tipped.
;;; After this you are added to the member list and can collect tips.
;;; Inspired by The Doge Tipping App
{
  ;;; Initialization
  [[0x00]] 1 ; Number of members
  [[0x01]] 0 ; Total times tipped
  [[0x02]] 0 ; Total splits tipped
  [[0x03]] 0 ; Total amount tipped
  [[0x10]] (caller) ; Admin is first member
  [[(caller)]] 1 ; Admin exists, give 1 wei to mark membership

  ;; Register with NameReg
  [0x0] "Make It Tes3" ; You can put a more specific name here
  (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0x0 12 0 0)
}
{
  ;;; Body
  (if (calldatasize)
    {
        ;; If the admin calls it with data "kill" deregister + suicide
        (when (and
                (= (caller) @@0x10)
                (= (calldataload 0) "kill"))
          {
            (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0 0 0 0)
            (suicide (caller))
          })

        (when (> (callvalue) 0)
          {
            ;; Pay everything to N random tippers
            [splits] (calldataload 0)
            ;; Splits should between 1 and min(members, 32)
            (when (< @@0x00 @splits)
              [splits] @@0x00)
            (when (> @splits 32)
              [splits] 32)
            (when (< @splits 1)
              [splits] 1)
            [split_tip_amount] (div (callvalue) @splits)

            ;; Update stats
            [[0x01]] (+ @@0x01 1) ; Times tipped
            [[0x02]] (+ @@0x02 @splits) ; Splits tipped
            [[0x03]] (+ @@0x03 (callvalue)) ; Amount tipped

            ;; Loop through splits and draw random member for each
            (for [cnt] 0 (< @cnt @splits) [cnt] (+ @cnt 1)
              {
                [random_data] (+ (prevhash) @cnt)
                [random_number] (sha3 random_data 0x20)
                [random_tipper] @@(+ (mod @random_number @@0x00) 0x09)
                [[@random_tipper]] (+ @@ @random_tipper @split_tip_amount)
              })

            ;; Add address of caller to storage, but only when he isn't a member yet
            (when (= @@(caller) 0)
              {
                [newest_member] (+ @@0x00 1)
                [[0x00]] @newest_member
                [[(+ @newest_member 0x09)]] (caller)
                [[(caller)]] 1 ; Mark the account as member by depositing 1 wei
              })
          })
      }
      ;; Called without data
      {
        ;;; Call without value to claim
        (when (> @@(caller) 1)
          {
            ;; Clear out their balance; except for 1 wei to mark membership
            (call (caller) (- @@(caller) 1) 0 0 0 0 0)
            [[(caller)]] 1
          })
      })
}
