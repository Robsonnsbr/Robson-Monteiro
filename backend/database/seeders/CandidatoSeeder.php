<?php

namespace Database\Seeders;

use App\Models\Candidato;
use Illuminate\Database\Seeder;

class CandidatoSeeder extends Seeder
{
    public function run(): void
    {
        Candidato::factory()->count(20)->create();
    }
}
