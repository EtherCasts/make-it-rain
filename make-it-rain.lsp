{
    ;;; Initialization
    [[0x0]] 1        ; Number of members
    [[0x1]] (caller) ; Admin is first member
    [[(caller)]] 1   ; Admin exists, give 1 wei

    ;; Register with NameReg
    [0x0] "Make It Tes3" ; You can put a more specific name here
    (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0 12 0 0)
}
{
    (if (calldatasize)
        ;; If the admin calls it with data "kill" deregister + suicide
        (when
            (and
                (= (caller) @@0x1)
                (= (calldataload 0) "kill"))
            {
                (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0 0 0 0)
                (suicide @@0x1)
            })

        ;; Called without data
        (if (> (callvalue) 0)
            {
                ;; Pay everything to previous tipper
                ; [previous_tipper] @@(+ @@0x0 0x1)
                ; [[@previous_tipper]] (+ @@ @previous_tipper (callvalue))

                ;; Pay everything to a random tipper
                [random_tipper] @@(+ (mod (prevhash) @@0x0) 0x1)
                [[@random_tipper]] (+ @@ @random_tipper (callvalue))

                ;; Add address of caller to storage, but only when he isn't a member yet
                (when (= @@(caller) 0)
                    {
                        [new_num_members] (+ @@0x0 1)
                        [[0x0]] @new_num_members
                        [[@new_num_members]] (caller)
                        [[(caller)]] 1 ; Mark the account as used by depositing 1 wei
                    })
            }
            {
                ;;; Call without value to claim
                (when (> @@(caller) 1)
                    {
                        ;; Clear out their balance; except for 1 wei to mark membership
                        (call (caller) (- @@(caller) 1) 0 0 0 0 0)
                        [[(caller)]] 1
                    })
            }))
}
