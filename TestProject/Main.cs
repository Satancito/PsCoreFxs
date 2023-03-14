using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;

public enum EnumTeamA
{
    First = 1,
    Second = 2,
    Third = 3,
    Fourth = 4,
    Fifth = 5
}

public enum EnumTeamB
{
    A = 100,
    B = 200,
    C = 300,
    D = 400,
    E = 500
}


public static class EnumExtensions
{
    private static ReadOnlyDictionary<EnumTeamA, EnumTeamB> TeamADictionary = new ReadOnlyDictionary<EnumTeamA, EnumTeamB>(new Dictionary<EnumTeamA, EnumTeamB>
        {
            { EnumTeamA.First, EnumTeamB.A},
            { EnumTeamA.Second, EnumTeamB.B},
            { EnumTeamA.Third, EnumTeamB.C},
            { EnumTeamA.Fourth, EnumTeamB.D},
            { EnumTeamA.Fifth, EnumTeamB.E}
        });
    private static ReadOnlyDictionary<EnumTeamB, EnumTeamA> TeamBDictionary = new ReadOnlyDictionary<EnumTeamB, EnumTeamA>(new Dictionary<EnumTeamB, EnumTeamA>
        {
            { EnumTeamB.A, EnumTeamA.First},
            { EnumTeamB.B, EnumTeamA.Second},
            { EnumTeamB.C, EnumTeamA.Third},
            { EnumTeamB.D, EnumTeamA.Fourth},
            { EnumTeamB.E, EnumTeamA.Fifth}
        });

    public static EnumTeamB Convert(this EnumTeamA key)
    {
        EnumTeamB value;
        bool ok = TeamADictionary.TryGetValue(key, out value);
        return ok ? value : throw new NotImplementedException("Invalid enum value: " + key.GetType().FullName);
    }

    public static EnumTeamA Convert(this EnumTeamB key)
    {
        EnumTeamA value;
        bool ok = TeamBDictionary.TryGetValue(key, out value);
        return ok ? value : throw new NotImplementedException("Invalid enum value: " + key.GetType().FullName);
    }
}

public static class Program
{
    public static void FunctionThatNeedsEnumTeamA(EnumTeamA value)
    {
        // Your custom code 
    }

    public static void FunctionThatNeedsEnumTeamB(EnumTeamB value)
    {
        // Your custom code
    }

    public static void Main()
    {
        // Context 1 - You have EnumTeamA value but need to call a function with EnumTeamB value.
        EnumTeamA enumTeamAValue = EnumTeamA.Fourth;
        FunctionThatNeedsEnumTeamB(enumTeamAValue.Convert());

        // Context 2 - You have EnumTeamB value but need to call a function with EnumTeamA value.
        EnumTeamB enumTeamBValue = EnumTeamB.D;
        FunctionThatNeedsEnumTeamA(enumTeamBValue.Convert());

        Console.ReadLine();
    }
}