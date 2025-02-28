import Result "mo:base/Result";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Map "mo:map/Map";
import Vector "mo:vector";
import {phash; nhash } "mo:map/Map";

actor {

    // Setup the variable to store the user with map and vector
    stable var nextId : Nat = 0; // to keep track of the next id
    stable var userIdMap : Map.Map<Principal, Nat> = Map.new<Principal, Nat>(); // to keep track of the user id
    stable var userProfileMap : Map.Map<Nat, Text> = Map.new<Nat, Text>(); // to keep track of the user profile (name)
    stable var userResultsMap : Map.Map<Nat, Vector.Vector<Text>> = Map.new<Nat, Vector.Vector<Text>>(); // to keep track of the user results

    // explain: 
    // stable var -> the variable will be stored in the canister state so it will be persisted across canaster upgrades
    // Caller -> the principal of the user who is calling the function

    public query ({ caller }) func getUserProfile() : async Result.Result<{ id : Nat; name : Text }, Text> {
        let userId = switch (Map.get(userIdMap, phash, caller)){
            case (?found) found ;
            case (_) return #err("User not found");
        };

        let name = switch (Map.get(userProfileMap, nhash, userId)){
            case (?found) found ;
            case (_) return #err("User not found");
        };

        return #ok({ id = userId; name = name });
    };

    public shared ({ caller }) func setUserProfile(name : Text) : async Result.Result<{ id : Nat; name : Text }, Text> {
        Debug.print("Principal: " #debug_show caller);
        var idRecorded = 0;
        // guardian clause to check if the use already exists
        switch (Map.get(userIdMap, phash, caller)) {
            case (?idFound) {
                // if the user already exists, return the user id
                Map.set(userIdMap, phash, caller, idFound);
                Map.set(userProfileMap, nhash, idFound, name);
                idRecorded := idFound;
            };
            case (_) {
                // if the user does not exist, create a new user
                Map.set(userIdMap,phash, caller, nextId);
                Map.set(userProfileMap, nhash, nextId, name);
                idRecorded := nextId;
                nextId += 1;
            };
        };
        return #ok({ id = idRecorded; name = name });
    };

    public shared ({ caller }) func addUserResult(result : Text) : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        // First get the user id from userIdMap
        let userId = switch (Map.get(userIdMap, phash, caller)){
            case (?found) found ;
            case (_) return #err("User not found");
        };

        // Then get existing result vector or create a new one
        let userResult = switch (Map.get(userResultsMap, nhash, userId)){
            case (?vector) vector ;
            case (_) {
                // if no vector exists, create a new one
                let newVector = Vector.new<Text>();
                Map.set(userResultsMap, nhash, userId, newVector);
                newVector;
            }
        };

        // Add the new result to the vector
        Vector.add(userResult, result);

        // Convert vector to array for return value
        let resultArray = Vector.toArray(userResult);

        return #ok({ id = userId; results = resultArray });
    };

    public query ({ caller }) func getUserResults() : async Result.Result<{ id : Nat; results : [Text] }, Text> {
        let userId = switch (Map.get(userIdMap, phash, caller)){
            case (?idFound) idFound ;
            case (_) return #err("User not found");
        };

        let result = switch (Map.get(userResultsMap, nhash, userId)){
            case (?vector) vector ;
            case (_) return #err("User result not found");
        };

        // Convert vector to array for return value
        let resultArray = Vector.toArray(result);
        
       return #ok({ id = userId; results = resultArray });
    };
};
