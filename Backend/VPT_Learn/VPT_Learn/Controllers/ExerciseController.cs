using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace VPT_Learn.Controllers
{
    [Authorize]
    [ApiController]
    [Route("api/exercises")]
    public class ExerciseController : ControllerBase
    {

    }
}
