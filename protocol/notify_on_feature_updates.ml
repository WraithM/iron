module Stable = struct

  open! Import_stable

  module Action = struct
    module V2 = struct
      type t =
        { feature_id : Feature_id.V1.t
        ; when_to_first_notify : When_to_first_notify.V1.t
        }
      [@@deriving bin_io, sexp]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 89dd9516c800dd8a7ab71368a54ba6a5 |}]
      ;;

      let to_model (t : t) = t
    end

    module V1 = struct
      type t = Feature_id.V1.t
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| d9a8da25d5656b016fb4dbdc2e4197fb |}]
      ;;

      let to_model feature_id =
        V2.to_model
          { feature_id
          ; when_to_first_notify = At_next_change
          }
      ;;
    end

    module Model = V2
  end

  module Reaction = struct
    module V4 = struct
      type t = [ `Updated of Feature.Stable.V20.t
               | `Archived
               ]
      [@@deriving bin_io, sexp_of]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| fc21f7faca14799d286aca9d4127b0f7 |}]
      ;;

      let of_model t = t
    end

    module V3 = struct
      type t = [ `Updated of Feature.Stable.V19.t
               | `Archived
               ]
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 064bd1a5d0ef4ce57177a26dc4cca7c3 |}]
      ;;

      let of_model = function
        | `Updated feature -> `Updated (Feature.Stable.V19.of_model feature)
        | `Archived as t -> t
      ;;
    end

    module V2 = struct
      type t = [ `Updated of Feature.Stable.V18.t
               | `Archived
               ]
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 58c7ad919e5d605c487243369eaa279a |}]
      ;;

      let of_model = function
        | `Updated feature -> `Updated (Feature.Stable.V18.of_model feature)
        | `Archived as t -> t
      ;;
    end

    module V1 = struct
      type t = [ `Updated of Feature.Stable.V17.t
               | `Archived
               ]
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 339a61c52f6cfa2a9a477f2abcde52db |}]
      ;;

      let of_model = function
        | `Updated feature -> `Updated (Feature.Stable.V17.of_model feature)
        | `Archived as t -> t
      ;;
    end

    module Model = V4
  end
end

include Iron_versioned_rpc.Make_pipe_rpc
    (struct let name = "notify-on-feature-updates" end)
    (struct let version = 4 end)
    (Stable.Action.V2)
    (Stable.Reaction.V4)

include Register_old_rpc
    (struct let version = 3 end)
    (Stable.Action.V2)
    (Stable.Reaction.V3)

include Register_old_rpc
    (struct let version = 2 end)
    (Stable.Action.V1)
    (Stable.Reaction.V2)

include Register_old_rpc
    (struct let version = 1 end)
    (Stable.Action.V1)
    (Stable.Reaction.V1)

module Action   = Stable.Action.   Model
module Reaction = Stable.Reaction. Model
