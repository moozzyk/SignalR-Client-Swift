namespace TestServer
{
    public enum Sex { Male, Female }

    public class Person
    {
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public int? Age { get; set; }
        public double? Height { get; set; }
        public Sex? Sex { get; set; }
    }
}