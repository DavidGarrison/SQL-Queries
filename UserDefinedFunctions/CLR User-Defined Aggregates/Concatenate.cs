using System;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Text;
using System.Linq;
using System.Collections.Generic;

[Serializable]
[Microsoft.SqlServer.Server.SqlUserDefinedAggregate(
	Format.UserDefined,
	IsInvariantToOrder = false,
	IsInvariantToNulls = true,
	IsInvariantToDuplicates = false,
	MaxByteSize = -1
	)]

public class Concatenate : IBinarySerialize
{
	public void Init()
	{
		m_stringsToConcatenate = new List<Tuple<int, string>>();
		m_delimiter = string.Empty;
	}

	public void Accumulate(SqlString value, SqlString delimiter, int maxCharactersPerSegment, int sortPrecedence = 0)
	{
		if (!delimiter.IsNull)
			m_delimiter = delimiter.Value;

		if (!value.IsNull)
			m_stringsToConcatenate.Add(Tuple.Create(sortPrecedence, Truncate(value.Value, maxCharactersPerSegment - m_delimiter.Length)));
	}

	public void Merge(Concatenate group)
	{
		m_stringsToConcatenate.AddRange(group.m_stringsToConcatenate);
	}

	public SqlString Terminate()
	{
		string str = string.Join(m_delimiter, m_stringsToConcatenate
			.OrderBy(o => o.Item1)
			.Select(s => s.Item2));

		return new SqlString(Truncate(str, c_maxCharactersReturned));
	}

	void IBinarySerialize.Write(System.IO.BinaryWriter w)
	{
		w.Write(m_delimiter);
		w.Write(m_stringsToConcatenate.Count);
		m_stringsToConcatenate.ForEach(f =>
		{
			w.Write(f.Item1);
			w.Write(f.Item2);
		});
	}

	void IBinarySerialize.Read(System.IO.BinaryReader r)
	{
		m_delimiter = r.ReadString();

		int numElements = r.ReadInt32();

		m_stringsToConcatenate = new List<Tuple<int, string>>();

		for (int i = 0; i < numElements; i++)
			m_stringsToConcatenate.Add(Tuple.Create(r.ReadInt32(), r.ReadString()));
	}

	private string Truncate(string value, int maxCharacters)
	{
		return value.Length > maxCharacters
			? value.Substring(0, maxCharacters)
			: value;
	}

	private List<Tuple<int, string>> m_stringsToConcatenate;
	private string m_delimiter;
	private const int c_maxCharactersReturned = 4000;
}