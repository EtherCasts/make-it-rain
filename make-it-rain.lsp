{
    ;Initialization
    [[0x0]] (caller) ;Admin!
    [[0x1]] 1      ;Number of members
    [[0x2]] (caller) ;Admin is first member
    [[(caller)]] 1 ;Admin exists, give 1 wei

    [0x0]:"Make It Tes3" ;You can put a more specific name here
    (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0 12 0 0) ;Register with name registration
}
{
    (if (calldatasize)
        (when
            (and
                (= (caller) @@0x0)
                (= (calldataload 0) "kill"))
                    ;If the admin calls it with data "kill" deregister + suicide
                    {
                        (call 0x11d11764cd7f6ecda172e0b72370e6ea7f75f290 0 0 0 0 0 0)
                        (suicide @@0x0)
                    }
        )
        (if (> (callvalue) 0)
            {
                ;pay everything to previous tipper
                [previous_tipper] @@(+ @@0x1 0x1)
                [[@previous_tipper]] (+ @@ @previous_tipper (callvalue))

                ;add address of caller to storage, but only when he isn't a member yet
                (when (= @@(caller) 0)
                    {
                        [new_num_members] (+ @@0x1 1)
                        [[0x1]] @new_num_members
                        [[(+ @new_num_members 0x1)]] (caller)
                        [[(caller)]] 1 ;mark the account as used by depositing 1 wei
                    })
            }
            {
                ;claim
                (when (> @@(caller) 1)
                    {
                        (call (caller) (- @@(caller) 1) 0 0 0 0 0)
                        [[(caller)]] 1; (almost) Clear out their balance; except for 1 wei
                    })
            }
        )
    )
}
